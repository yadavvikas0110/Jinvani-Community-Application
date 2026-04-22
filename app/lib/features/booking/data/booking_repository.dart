import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';

class BookingRepository {
  static int _bookingCounter = 1;

  final List<Property> _properties = [
    Property(
      id: 'p1',
      title: 'Shri Mahavir Dharamshala',
      location: 'Palitana, Gujarat',
      type: 'dharamshala',
      rating: 4.8,
      reviewCount: 312,
      imageUrls: [
        'https://images.unsplash.com/photo-1601918774946-25832a4be0d6?w=800',
      ],
      description:
          'Nestled in the serene hills of Palitana, perfect for spiritual retreats and peaceful meditation. Adjacent to the sacred Shatrunjaya hills.',
      amenities: ['Free WiFi', 'Parking', 'Temple Nearby'],
      rooms: [
        const RoomType(id: 'r1a', name: 'Economy Room', pricePerNight: 500, maxGuests: 2, availableRooms: 8),
        const RoomType(id: 'r1b', name: 'Deluxe Room', pricePerNight: 800, maxGuests: 4, availableRooms: 5),
        const RoomType(id: 'r1c', name: 'Family Suite', pricePerNight: 1200, maxGuests: 6, availableRooms: 3),
      ],
      lat: 21.5222,
      lng: 71.8237,
    ),
    Property(
      id: 'p2',
      title: 'Jain Heritage Hotel',
      location: 'Patna, Bihar',
      type: 'hotel',
      rating: 4.8,
      reviewCount: 189,
      imageUrls: [
        'https://images.unsplash.com/photo-1598977054346-5ee26d7a8e7a?w=800',
      ],
      description:
          'A heritage property offering comfortable stays with a blend of modern amenities and traditional Jain hospitality near major temples.',
      amenities: ['Free WiFi', 'Parking', 'Temple Nearby'],
      rooms: [
        const RoomType(id: 'r2a', name: 'Standard Room', pricePerNight: 500, maxGuests: 2, availableRooms: 10),
        const RoomType(id: 'r2b', name: 'Deluxe Room', pricePerNight: 900, maxGuests: 3, availableRooms: 6),
      ],
      lat: 25.5941,
      lng: 85.1376,
    ),
    Property(
      id: 'p3',
      title: 'Royal Jain Palace',
      location: 'Jaipur, Rajasthan',
      type: 'hotel',
      rating: 4.8,
      reviewCount: 241,
      imageUrls: [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      ],
      description:
          'A majestic palace-style hotel offering luxurious stays with beautiful Rajasthani architecture and proximity to Jain pilgrimage sites.',
      amenities: ['Free WiFi', 'Parking', 'Temple Nearby'],
      rooms: [
        const RoomType(id: 'r3a', name: 'Economy Room', pricePerNight: 500, maxGuests: 2, availableRooms: 12),
        const RoomType(id: 'r3b', name: 'Deluxe Room', pricePerNight: 1000, maxGuests: 4, availableRooms: 7),
        const RoomType(id: 'r3c', name: 'Royal Suite', pricePerNight: 2500, maxGuests: 4, availableRooms: 2),
      ],
      lat: 26.9124,
      lng: 75.7873,
    ),
    Property(
      id: 'p4',
      title: 'Adinanath Dharamshala',
      location: 'Mount Abu, Rajasthan',
      type: 'dharamshala',
      rating: 4.8,
      reviewCount: 312,
      imageUrls: [
        'https://images.unsplash.com/photo-1601918774946-25832a4be0d6?w=800',
      ],
      description:
          'Nestled in the serene hills of Mount Abu, perfect for spiritual retreats and peaceful meditation near the Dilwara Temples.',
      amenities: ['Mountain View', 'Prayer Room', 'Library', 'Herbal Garden'],
      rooms: [
        const RoomType(id: 'r4a', name: 'Economy Room', pricePerNight: 800, maxGuests: 4, availableRooms: 8),
        const RoomType(id: 'r4b', name: 'Deluxe Room', pricePerNight: 1200, maxGuests: 4, availableRooms: 5),
        const RoomType(id: 'r4c', name: 'Family Room', pricePerNight: 1600, maxGuests: 6, availableRooms: 3),
      ],
      lat: 24.5926,
      lng: 72.7156,
    ),
    Property(
      id: 'p5',
      title: 'Shri Parshwanath Dharamshala',
      location: 'Girnar, Gujarat',
      type: 'dharamshala',
      rating: 4.6,
      reviewCount: 98,
      imageUrls: [
        'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?w=800',
      ],
      description:
          'Located at the foothills of the sacred Girnar mountain, ideal for pilgrims visiting the Jain temples on Girnar.',
      amenities: ['Free WiFi', 'Temple Nearby', 'Parking'],
      rooms: [
        const RoomType(id: 'r5a', name: 'Standard Room', pricePerNight: 500, maxGuests: 2, availableRooms: 15),
        const RoomType(id: 'r5b', name: 'Deluxe Room', pricePerNight: 800, maxGuests: 4, availableRooms: 8),
      ],
      lat: 21.5167,
      lng: 70.5333,
    ),
  ];

  final List<Booking> _bookings = [];

  Future<List<Property>> fetchProperties({String? typeFilter, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = List<Property>.from(_properties);
    if (typeFilter != null && typeFilter != 'All') {
      final t = typeFilter.toLowerCase() == 'hotels' ? 'hotel' : 'dharamshala';
      list = list.where((p) => p.type == t).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.location.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<Property?> fetchPropertyById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _properties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> toggleSave(String propertyId) async {
    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx == -1) return false;
    _properties[idx] =
        _properties[idx].copyWith(isSaved: !_properties[idx].isSaved);
    return true;
  }

  Future<Booking> createBooking({
    required String propertyId,
    required RoomType room,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int roomCount,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required String specialRequests,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final property = _properties.firstWhere((p) => p.id == propertyId);
    final nights = checkOut.difference(checkIn).inDays;
    final base = room.pricePerNight * nights * roomCount;
    final tax = base * 0.12;
    final total = base + tax;
    final ref = 'BK${_bookingCounter.toString().padLeft(3, '0')}';
    _bookingCounter++;
    final txnId =
        'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final booking = Booking(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      bookingRef: ref,
      propertyId: propertyId,
      propertyTitle: property.title,
      propertyLocation: property.location,
      propertyType: property.type,
      propertyImageUrl: property.primaryImage,
      roomType: room.name,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      roomCount: roomCount,
      totalPrice: total,
      status: 'upcoming',
      paymentStatus: 'paid',
      paymentMethod: paymentMethod,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      transactionId: txnId,
    );
    _bookings.add(booking);
    return booking;
  }

  Future<List<Booking>> fetchMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List<Booking>.from(_bookings.reversed);
  }

  Future<Booking?> fetchBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelBooking(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: 'cancelled',
        paymentStatus: 'refunded',
      );
    }
  }
}

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => BookingRepository());
