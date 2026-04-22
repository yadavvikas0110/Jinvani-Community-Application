import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/location_repository.dart';
import '../models/jain_location.dart';

// ── Params record ─────────────────────────────────────────────────────────────

typedef LocationParams = ({String category, String search});

// ── Location list ─────────────────────────────────────────────────────────────

final locationListProvider =
    FutureProvider.family<List<JainLocation>, LocationParams>(
        (ref, params) async {
  return ref.read(locationRepositoryProvider).fetchLocations(
        category: params.category,
        search: params.search.isEmpty ? null : params.search,
      );
});

// ── Location detail ───────────────────────────────────────────────────────────

final locationDetailProvider =
    FutureProvider.family<JainLocation?, String>((ref, id) async {
  return ref.read(locationRepositoryProvider).fetchLocationById(id);
});
