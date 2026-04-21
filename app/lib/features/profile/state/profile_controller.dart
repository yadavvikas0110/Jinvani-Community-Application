import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../models/profile.dart';

class ProfileState {
  final bool loading;
  final Profile? profile;
  final String? error;

  const ProfileState({this.loading = false, this.profile, this.error});

  ProfileState copyWith({bool? loading, Profile? profile, String? error, bool clearError = false}) =>
      ProfileState(
        loading: loading ?? this.loading,
        profile: profile ?? this.profile,
        error: clearError ? null : error ?? this.error,
      );
}

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repo = ref.read(profileRepositoryProvider);

  @override
  ProfileState build() {
    _load();
    return const ProfileState(loading: true);
  }

  Future<void> _load() async {
    try {
      final p = await _repo.getProfile();
      state = ProfileState(profile: p);
    } catch (e) {
      state = ProfileState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    await _load();
  }

  Future<void> _applyUpdate(Future<Profile> Function() op) async {
    state = state.copyWith(loading: true, clearError: true);
    final p = await op();
    state = ProfileState(profile: p);
  }

  Future<void> savePersonal(Map<String, dynamic> data) =>
      _applyUpdate(() => _repo.updatePersonal(data));

  Future<void> addEducation(Map<String, dynamic> data) =>
      _applyUpdate(() => _repo.addEducation(data));

  Future<void> updateEducation(String id, Map<String, dynamic> data) =>
      _applyUpdate(() => _repo.updateEducation(id, data));

  Future<void> deleteEducation(String id) => _applyUpdate(() => _repo.deleteEducation(id));

  Future<void> saveWork(Map<String, dynamic> data) => _applyUpdate(() => _repo.updateWork(data));

  Future<void> saveEconomic(Map<String, dynamic> data) =>
      _applyUpdate(() => _repo.updateEconomic(data));

  Future<void> saveBio(Map<String, dynamic> data) => _applyUpdate(() => _repo.updateBio(data));

  Future<void> saveGoals(List<String> goals) => _applyUpdate(() => _repo.updateGoals(goals));

  Future<String> uploadFile(String path, String filename) =>
      _repo.uploadFile(path, filename);
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
