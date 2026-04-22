import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jain_location.dart';

class LocationRepository {
  final _saved = <String>{};

  static final List<JainLocation> _locations = [
    // ── Historical ────────────────────────────────────────────────────────────
    JainLocation(
      id: 'palitana',
      name: 'Palitana Temples',
      category: 'historical',
      address: 'Shatrunjaya Hills, Palitana',
      city: 'Palitana',
      state: 'Gujarat',
      rating: 4.9,
      reviewCount: 3240,
      description:
          'Palitana is the most sacred pilgrimage site for Jains. Situated on Shatrunjaya Hill, it has over 900 temples built over 900 years. The hill is climbed via 3,800 steps and is considered so sacred that no one is permitted to spend the night on the hill. It is the only city in the world to have been declared vegetarian by law.',
      imageUrls: [
        'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=800',
        'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800',
      ],
    ),
    JainLocation(
      id: 'ranakpur',
      name: 'Ranakpur Jain Temple',
      category: 'historical',
      address: 'Ranakpur, Desuri Tehsil',
      city: 'Pali',
      state: 'Rajasthan',
      rating: 4.8,
      reviewCount: 2180,
      description:
          'One of the largest and most important Jain temples in India, Ranakpur Temple is dedicated to Adinath (Rishabhadeva), the first Tirthankara. Built in the 15th century, it is renowned for its extraordinary marble architecture with 1,444 uniquely carved pillars — no two are alike. The temple took over 50 years to build.',
      imageUrls: [
        'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
        'https://images.unsplash.com/photo-1598091383021-15ddea10925d?w=800',
      ],
    ),
    JainLocation(
      id: 'dilwara',
      name: 'Dilwara Temples',
      category: 'historical',
      address: 'Mount Abu, Sirohi District',
      city: 'Mount Abu',
      state: 'Rajasthan',
      rating: 4.8,
      reviewCount: 1950,
      description:
          'The Dilwara Temples are considered among the most beautiful Jain pilgrimage sites in the world. Built between the 11th and 13th centuries, these five marble temples are famous for their incredible intricate carvings. The Vimal Vasahi temple (1031 CE) and Luna Vasahi temple (1231 CE) are the most celebrated.',
      imageUrls: [
        'https://images.unsplash.com/photo-1568454537842-d933259bb258?w=800',
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
      ],
    ),
    JainLocation(
      id: 'shravanabelagola',
      name: 'Shravanabelagola',
      category: 'historical',
      address: 'Vindhyagiri & Chandragiri Hills',
      city: 'Hassan District',
      state: 'Karnataka',
      rating: 4.7,
      reviewCount: 1620,
      description:
          'Home to the monolithic statue of Gomateshwara (Bahubali), one of the largest free-standing statues in the world at 57 feet. Carved from a single block of granite in 981 CE, it is the most important pilgrimage site for Digambara Jains. The Mahamastakabhisheka festival is held every 12 years.',
      imageUrls: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=800',
      ],
    ),
    JainLocation(
      id: 'girnar',
      name: 'Girnar Jain Temples',
      category: 'historical',
      address: 'Girnar Hills, Junagadh',
      city: 'Junagadh',
      state: 'Gujarat',
      rating: 4.6,
      reviewCount: 1340,
      description:
          'Girnar is a sacred hill with a cluster of Jain temples at an altitude of around 3,600 feet. The temples are dedicated to Neminath, the 22nd Tirthankara, who is believed to have attained moksha here. Pilgrims climb 9,999 steps to reach the summit temples.',
      imageUrls: [
        'https://images.unsplash.com/photo-1561361058-c24cecae35ca?w=800',
      ],
    ),
    JainLocation(
      id: 'sonagiri',
      name: 'Sonagiri Temples',
      category: 'historical',
      address: 'Sonagiri Village, Datia District',
      city: 'Datia',
      state: 'Madhya Pradesh',
      rating: 4.5,
      reviewCount: 870,
      description:
          'Sonagiri means "Golden Peak" and is a major Digambara Jain pilgrimage site. The hilltop is dotted with 77 Jain temples, the most important being the Chandraprabhu temple dedicated to the 8th Tirthankara. A beautiful, peaceful site away from the crowds.',
      imageUrls: [
        'https://images.unsplash.com/photo-1532375810709-75b1da00537c?w=800',
      ],
    ),

    // ── Devotional ────────────────────────────────────────────────────────────
    JainLocation(
      id: 'siddhachalam',
      name: 'Siddhachalam Tirtha',
      category: 'devotional',
      address: 'Mussoorie Road, Blairstown',
      city: 'Blairstown',
      state: 'New Jersey, USA',
      rating: 4.7,
      reviewCount: 540,
      description:
          'The first Jain tirtha (pilgrimage site) outside of India, Siddhachalam is set in the mountains of New Jersey. Founded by Gurudev Chitrabhanu, it is a spiritual retreat centre with temples, meditation halls, and the famous 35-foot Gomateshwara statue.',
      imageUrls: [
        'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
      ],
    ),
    JainLocation(
      id: 'ahinsa_sthal',
      name: 'Ahinsa Sthal',
      category: 'devotional',
      address: 'Mehrauli, South Delhi',
      city: 'New Delhi',
      state: 'Delhi',
      rating: 4.4,
      reviewCount: 780,
      description:
          'A serene Jain park in South Delhi featuring a large marble statue of Bahubali surrounded by beautifully manicured gardens. It is a popular spot for meditation, morning walks, and community gatherings. The park embodies the Jain principle of non-violence (Ahimsa).',
      imageUrls: [
        'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=800',
      ],
    ),
    JainLocation(
      id: 'mahudi',
      name: 'Mahudi Shree Ghantakarna Mahavir',
      category: 'devotional',
      address: 'Mahudi Village, Mehsana District',
      city: 'Mahudi',
      state: 'Gujarat',
      rating: 4.6,
      reviewCount: 1120,
      description:
          'The most famous Shasan Devi temple of the Jain faith, dedicated to Ghantakarna Mahavir. Devotees from across the world visit to seek blessings and fulfil wishes. The temple is known for its miraculous powers and thousands of devotees visit during festivals.',
      imageUrls: [
        'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
      ],
    ),

    // ── Dharmshala ────────────────────────────────────────────────────────────
    JainLocation(
      id: 'jain_dharmshala_palitana',
      name: 'Palitana Jain Dharmshala',
      category: 'dharmshala',
      address: 'Near Taleti Gate, Palitana',
      city: 'Palitana',
      state: 'Gujarat',
      rating: 4.3,
      reviewCount: 460,
      description:
          'A large pilgrim rest house at the base of Shatrunjaya Hill. Provides clean, affordable accommodation for pilgrims visiting the Palitana temples. Meals, lockers, and a vehicle park are available. Managed by the local Jain Sangh.',
      imageUrls: [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      ],
    ),
    JainLocation(
      id: 'jain_dharmshala_ranakpur',
      name: 'Ranakpur Dharmshala',
      category: 'dharmshala',
      address: 'Near Ranakpur Temple, Pali',
      city: 'Pali',
      state: 'Rajasthan',
      rating: 4.2,
      reviewCount: 310,
      description:
          'An accommodation facility managed by the Ranakpur temple trust. Provides rooms, dormitories, and a pure vegetarian kitchen for pilgrims. Located within walking distance of the magnificent Ranakpur temples.',
      imageUrls: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      ],
    ),
    JainLocation(
      id: 'jain_bhawan_mumbai',
      name: 'Jain Bhawan Mumbai',
      category: 'dharmshala',
      address: 'Walkeshwar Road, Malabar Hill',
      city: 'Mumbai',
      state: 'Maharashtra',
      rating: 4.5,
      reviewCount: 520,
      description:
          'A premier Jain community centre and guest house in the heart of Mumbai. Offers well-furnished rooms, a community hall, and a Jain library. Ideal for community meetings, religious events, and pilgrims visiting Mumbai.',
      imageUrls: [
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      ],
    ),
    JainLocation(
      id: 'jain_dharmshala_ahmedabad',
      name: 'Ahmedabad Jain Dharmshala',
      category: 'dharmshala',
      address: 'Kalupur, Near Hathisingh Temple',
      city: 'Ahmedabad',
      state: 'Gujarat',
      rating: 4.1,
      reviewCount: 280,
      description:
          'A heritage dharmshala near the famous Hathisingh Jain Temple in the old walled city of Ahmedabad. Provides basic, clean accommodation with a community kitchen. Easy access to multiple Jain temples in the old city.',
      imageUrls: [
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
      ],
    ),
  ];

  Future<List<JainLocation>> fetchLocations({
    required String category,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    var list = category == 'all'
        ? List<JainLocation>.from(_locations)
        : _locations.where((l) => l.category == category).toList();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((l) =>
              l.name.toLowerCase().contains(q) ||
              l.city.toLowerCase().contains(q) ||
              l.state.toLowerCase().contains(q) ||
              l.address.toLowerCase().contains(q))
          .toList();
    }
    // Apply saved state
    return list
        .map((l) => _saved.contains(l.id) ? l.copyWith(isSaved: true) : l)
        .toList();
  }

  Future<JainLocation?> fetchLocationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final l = _locations.firstWhere((l) => l.id == id);
      return _saved.contains(l.id) ? l.copyWith(isSaved: true) : l;
    } catch (_) {
      return null;
    }
  }

  void toggleSave(String id) {
    if (_saved.contains(id)) {
      _saved.remove(id);
    } else {
      _saved.add(id);
    }
  }
}

final locationRepositoryProvider =
    Provider<LocationRepository>((_) => LocationRepository());
