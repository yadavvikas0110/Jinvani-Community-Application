import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job.dart';

class SeekerSetupController extends Notifier<SeekerProfile> {
  static const _setupDoneKey = 'jobs_seeker_setup_done';

  @override
  SeekerProfile build() => const SeekerProfile();

  void setRole(String role) => state = state.copyWith(role: role);

  void setPersonalInfo({
    required String fullName,
    required String email,
    required String location,
    required String mobile,
  }) =>
      state = state.copyWith(
        fullName: fullName,
        email: email,
        location: location,
        mobile: mobile,
      );

  void setProfessionalInfo({
    required String professionalProfile,
    required String professionalSummary,
    required String workExperience,
  }) =>
      state = state.copyWith(
        professionalProfile: professionalProfile,
        professionalSummary: professionalSummary,
        workExperience: workExperience,
      );

  void setCv({String? cvUrl, String? portfolio}) =>
      state = state.copyWith(cvUrl: cvUrl, portfolio: portfolio);

  Future<void> completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupDoneKey, true);
  }

  static Future<bool> isSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_setupDoneKey) ?? false;
  }
}

final seekerSetupProvider = NotifierProvider<SeekerSetupController, SeekerProfile>(
  SeekerSetupController.new,
);

final seekerSetupDoneProvider = FutureProvider<bool>((ref) async {
  return SeekerSetupController.isSetupDone();
});
