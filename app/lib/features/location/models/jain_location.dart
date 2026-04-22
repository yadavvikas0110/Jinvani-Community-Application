class JainLocation {
  final String id;
  final String name;
  final String category; // all | dharmshala | historical | devotional
  final String address;
  final String city;
  final String state;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> imageUrls;
  final bool isSaved;

  const JainLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.city,
    required this.state,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.imageUrls,
    this.isSaved = false,
  });

  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  JainLocation copyWith({bool? isSaved}) => JainLocation(
        id: id,
        name: name,
        category: category,
        address: address,
        city: city,
        state: state,
        rating: rating,
        reviewCount: reviewCount,
        description: description,
        imageUrls: imageUrls,
        isSaved: isSaved ?? this.isSaved,
      );
}

const locationCategories = [
  LocationCategory(id: 'all',        label: 'All Locations'),
  LocationCategory(id: 'dharmshala', label: 'Dharmshala'),
  LocationCategory(id: 'historical', label: 'Historical'),
  LocationCategory(id: 'devotional', label: 'Devotional'),
];

class LocationCategory {
  final String id;
  final String label;
  const LocationCategory({required this.id, required this.label});
}
