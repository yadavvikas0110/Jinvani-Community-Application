// ── Room type ─────────────────────────────────────────────────────────────────

class RoomType {
  final String id;
  final String name;
  final double pricePerNight;
  final int maxGuests;
  final int availableRooms;

  const RoomType({
    required this.id,
    required this.name,
    required this.pricePerNight,
    required this.maxGuests,
    required this.availableRooms,
  });
}

// ── Property ──────────────────────────────────────────────────────────────────

class Property {
  final String id;
  final String title;
  final String location; // "City, State" format
  final String type; // 'hotel' | 'dharamshala'
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final String description;
  final List<String> amenities;
  final List<RoomType> rooms;
  final double? lat;
  final double? lng;
  bool isSaved;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.description,
    required this.amenities,
    required this.rooms,
    this.lat,
    this.lng,
    this.isSaved = false,
  });

  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  double get startingPrice => rooms.isEmpty
      ? 0
      : rooms
          .map((r) => r.pricePerNight)
          .reduce((a, b) => a < b ? a : b);

  Property copyWith({bool? isSaved}) => Property(
        id: id,
        title: title,
        location: location,
        type: type,
        rating: rating,
        reviewCount: reviewCount,
        imageUrls: imageUrls,
        description: description,
        amenities: amenities,
        rooms: rooms,
        lat: lat,
        lng: lng,
        isSaved: isSaved ?? this.isSaved,
      );
}

// ── Booking ───────────────────────────────────────────────────────────────────

class Booking {
  final String id;
  final String bookingRef;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String propertyType;
  final String? propertyImageUrl;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int roomCount;
  final double totalPrice;
  final String status; // 'upcoming' | 'completed' | 'cancelled'
  final String paymentStatus; // 'paid' | 'pending' | 'refunded'
  final String paymentMethod;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String transactionId;

  const Booking({
    required this.id,
    required this.bookingRef,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.propertyType,
    this.propertyImageUrl,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.roomCount,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.transactionId,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  Booking copyWith({String? status, String? paymentStatus}) => Booking(
        id: id,
        bookingRef: bookingRef,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        propertyLocation: propertyLocation,
        propertyType: propertyType,
        propertyImageUrl: propertyImageUrl,
        roomType: roomType,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        roomCount: roomCount,
        totalPrice: totalPrice,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paymentMethod: paymentMethod,
        guestName: guestName,
        guestEmail: guestEmail,
        guestPhone: guestPhone,
        transactionId: transactionId,
      );
}

// ── Property type filters ─────────────────────────────────────────────────────

const List<String> propertyTypeFilters = ['All', 'Hotels', 'Dharamshala'];
