import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/directory_repository.dart';
import '../models/directory_member.dart';

// ── Params record (category + search + tag filters) ───────────────────────────

typedef DirectoryParams = ({
  String category,
  String search,
  List<String> tags,
});

// ── Member list (keyed by params) ─────────────────────────────────────────────

final directoryMembersProvider =
    FutureProvider.family<List<DirectoryMember>, DirectoryParams>(
        (ref, params) async {
  return ref.read(directoryRepositoryProvider).fetchMembers(
        category: params.category,
        search: params.search.isEmpty ? null : params.search,
        tags: params.tags.isEmpty ? null : params.tags,
      );
});

// ── Member detail ─────────────────────────────────────────────────────────────

final directoryMemberProvider =
    FutureProvider.family<DirectoryMember?, String>((ref, id) async {
  return ref.read(directoryRepositoryProvider).fetchMemberById(id);
});

// ── Category counts ───────────────────────────────────────────────────────────

final directoryCategoryCountsProvider = Provider<Map<String, int>>((ref) {
  return ref.read(directoryRepositoryProvider).getCategoryCounts();
});

// ── Featured members ──────────────────────────────────────────────────────────

final directoryFeaturedProvider = Provider<List<DirectoryMember>>((ref) {
  return ref.read(directoryRepositoryProvider).getFeaturedMembers();
});
