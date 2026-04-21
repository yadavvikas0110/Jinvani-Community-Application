import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/state/profile_controller.dart';
import '../data/family_repository.dart';
import '../models/family.dart';

class FamilyState {
  final bool loading;
  final FamilySnapshot? data;
  final String? error;
  const FamilyState({this.loading = false, this.data, this.error});

  FamilyState copyWith({
    bool? loading,
    FamilySnapshot? data,
    String? error,
    bool clearError = false,
  }) =>
      FamilyState(
        loading: loading ?? this.loading,
        data: data ?? this.data,
        error: clearError ? null : error ?? this.error,
      );
}

class FamilyController extends Notifier<FamilyState> {
  late final FamilyRepository _repo = ref.read(familyRepositoryProvider);

  @override
  FamilyState build() {
    _load();
    return const FamilyState(loading: true);
  }

  Future<void> _load() async {
    try {
      final snap = await _repo.getFamily();
      state = FamilyState(data: snap);
    } catch (e) {
      state = FamilyState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    await _load();
  }

  Future<InviteResult> invite({
    required String name,
    required String relation,
    String? phone,
    String? email,
  }) async {
    final result = await _repo.invite(
      name: name,
      relation: relation,
      phone: phone,
      email: email,
    );
    if (result.status == 'sent') {
      await refresh();
    }
    return result;
  }

  Future<InviteResult> sendExternalInvite({
    required String name,
    required String relation,
    String? phone,
    String? email,
  }) async {
    final result = await _repo.sendExternalInvite(
      name: name,
      relation: relation,
      phone: phone,
      email: email,
    );
    if (result.status == 'sent') {
      await refresh();
    }
    return result;
  }

  Future<void> accept(String invitationId) async {
    await _repo.accept(invitationId);
    await refresh();
    ref.read(profileControllerProvider.notifier).refresh();
  }

  Future<void> reject(String invitationId) async {
    await _repo.reject(invitationId);
    await refresh();
  }

  Future<void> cancel(String invitationId) async {
    await _repo.cancel(invitationId);
    await refresh();
  }

  Future<void> removeMember(String memberId) async {
    await _repo.removeMember(memberId);
    await refresh();
    ref.read(profileControllerProvider.notifier).refresh();
  }
}

final familyControllerProvider =
    NotifierProvider<FamilyController, FamilyState>(FamilyController.new);
