import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../models/property.dart';

// ── Properties state ──────────────────────────────────────────────────────────

class PropertiesState {
  final List<Property> properties;
  final bool loading;
  final String? error;
  final String typeFilter; // 'All' | 'Hotels' | 'Dharamshala'
  final String searchQuery;

  const PropertiesState({
    this.properties = const [],
    this.loading = false,
    this.error,
    this.typeFilter = 'All',
    this.searchQuery = '',
  });

  PropertiesState copyWith({
    List<Property>? properties,
    bool? loading,
    String? error,
    String? typeFilter,
    String? searchQuery,
  }) =>
      PropertiesState(
        properties: properties ?? this.properties,
        loading: loading ?? this.loading,
        error: error,
        typeFilter: typeFilter ?? this.typeFilter,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class PropertiesController extends Notifier<PropertiesState> {
  @override
  PropertiesState build() {
    Future.microtask(() => _load());
    return const PropertiesState(loading: true);
  }

  BookingRepository get _repo => ref.read(bookingRepositoryProvider);

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _repo.fetchProperties(
        typeFilter: state.typeFilter == 'All' ? null : state.typeFilter,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      state = state.copyWith(properties: list, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void selectType(String type) {
    state = state.copyWith(typeFilter: type);
    _load();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _load();
  }

  Future<void> toggleSave(String propertyId) async {
    await _repo.toggleSave(propertyId);
    _load();
  }

  void reload() => _load();
}

final propertiesControllerProvider =
    NotifierProvider<PropertiesController, PropertiesState>(
        PropertiesController.new);

final propertyDetailProvider =
    FutureProvider.family<Property?, String>((ref, id) async {
  return ref.read(bookingRepositoryProvider).fetchPropertyById(id);
});

// ── My Bookings state ─────────────────────────────────────────────────────────

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return ref.read(bookingRepositoryProvider).fetchMyBookings();
});

final bookingDetailProvider =
    FutureProvider.family<Booking?, String>((ref, id) async {
  return ref.read(bookingRepositoryProvider).fetchBookingById(id);
});

// ── Checkout state ────────────────────────────────────────────────────────────

class CheckoutState {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final int roomCount;
  final RoomType? selectedRoom;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String specialRequests;
  final String paymentMethod;
  final bool submitting;
  final String? error;

  const CheckoutState({
    this.checkIn,
    this.checkOut,
    this.guests = 2,
    this.roomCount = 1,
    this.selectedRoom,
    this.guestName = '',
    this.guestEmail = '',
    this.guestPhone = '',
    this.specialRequests = '',
    this.paymentMethod = 'UPI',
    this.submitting = false,
    this.error,
  });

  int get nights =>
      (checkIn != null && checkOut != null)
          ? checkOut!.difference(checkIn!).inDays
          : 0;

  double get basePrice =>
      (selectedRoom != null && nights > 0)
          ? selectedRoom!.pricePerNight * nights * roomCount
          : 0;

  double get taxes => basePrice * 0.12;
  double get total => basePrice + taxes;

  CheckoutState copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    int? roomCount,
    RoomType? selectedRoom,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? specialRequests,
    String? paymentMethod,
    bool? submitting,
    String? error,
  }) =>
      CheckoutState(
        checkIn: checkIn ?? this.checkIn,
        checkOut: checkOut ?? this.checkOut,
        guests: guests ?? this.guests,
        roomCount: roomCount ?? this.roomCount,
        selectedRoom: selectedRoom ?? this.selectedRoom,
        guestName: guestName ?? this.guestName,
        guestEmail: guestEmail ?? this.guestEmail,
        guestPhone: guestPhone ?? this.guestPhone,
        specialRequests: specialRequests ?? this.specialRequests,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        submitting: submitting ?? this.submitting,
        error: error,
      );
}

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setDates(DateTime checkIn, DateTime checkOut) =>
      state = state.copyWith(checkIn: checkIn, checkOut: checkOut);

  void setGuests(int guests) => state = state.copyWith(guests: guests);

  void setRoomCount(int count) => state = state.copyWith(roomCount: count);

  void selectRoom(RoomType room) =>
      state = state.copyWith(selectedRoom: room);

  void setGuestName(String v) => state = state.copyWith(guestName: v);
  void setGuestEmail(String v) => state = state.copyWith(guestEmail: v);
  void setGuestPhone(String v) => state = state.copyWith(guestPhone: v);
  void setSpecialRequests(String v) =>
      state = state.copyWith(specialRequests: v);

  void setPaymentMethod(String method) =>
      state = state.copyWith(paymentMethod: method);

  Future<Booking?> confirmBooking(String propertyId) async {
    if (state.checkIn == null ||
        state.checkOut == null ||
        state.selectedRoom == null) return null;
    state = state.copyWith(submitting: true, error: null);
    try {
      final booking =
          await ref.read(bookingRepositoryProvider).createBooking(
                propertyId: propertyId,
                room: state.selectedRoom!,
                checkIn: state.checkIn!,
                checkOut: state.checkOut!,
                guests: state.guests,
                roomCount: state.roomCount,
                guestName: state.guestName,
                guestEmail: state.guestEmail,
                guestPhone: state.guestPhone,
                specialRequests: state.specialRequests,
                paymentMethod: state.paymentMethod,
              );
      state = state.copyWith(submitting: false);
      ref.invalidate(myBookingsProvider);
      return booking;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const CheckoutState();
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(
        CheckoutController.new);
