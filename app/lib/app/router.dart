import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/forgot_password_otp_screen.dart';
import '../features/auth/screens/forgot_password_reset_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_details_screen.dart';
import '../features/auth/screens/signup_otp_screen.dart';
import '../features/auth/screens/signup_password_screen.dart';
import '../features/auth/screens/signup_roles_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/family/screens/add_family_member_screen.dart';
import '../features/family/screens/family_request_detail_screen.dart';
import '../features/family/screens/family_requests_screen.dart';
import '../features/family/screens/family_tree_hub_screen.dart';
import '../features/calendar/screens/jain_calendar_screen.dart';
import '../features/location/screens/jain_location_detail_screen.dart';
import '../features/location/screens/jain_location_screen.dart';
import '../features/directory/screens/directory_list_screen.dart';
import '../features/directory/screens/directory_member_profile_screen.dart';
import '../features/directory/screens/directory_screen.dart';
import '../features/booking/screens/booking_checkout_screen.dart';
import '../features/booking/screens/booking_confirmed_screen.dart';
import '../features/booking/screens/booking_detail_screen.dart';
import '../features/booking/screens/booking_payment_screen.dart';
import '../features/booking/screens/booking_screen.dart';
import '../features/booking/screens/my_bookings_screen.dart';
import '../features/booking/screens/property_detail_screen.dart';
import '../features/booking/screens/property_list_screen.dart';
import '../features/feed/screens/feed_screen.dart';
import '../features/feed/screens/post_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jobs/screens/applied_jobs_screen.dart';
import '../features/jobs/screens/job_application_result_screen.dart';
import '../features/jobs/screens/job_apply_screen.dart';
import '../features/jobs/screens/job_cv_upload_screen.dart';
import '../features/jobs/screens/job_detail_screen.dart';
import '../features/jobs/screens/job_personal_info_screen.dart';
import '../features/jobs/screens/job_professional_profile_screen.dart';
import '../features/jobs/screens/job_role_selection_screen.dart';
import '../features/jobs/screens/jobs_screen.dart';
import '../features/jobs/screens/saved_jobs_screen.dart';
import '../features/profile/screens/bio_screen.dart';
import '../features/profile/screens/economic_data_screen.dart';
import '../features/profile/screens/education_screen.dart';
import '../features/profile/screens/goals_screen.dart';
import '../features/profile/screens/personal_details_screen.dart';
import '../features/profile/screens/profile_menu_screen.dart';
import '../features/profile/screens/verify_email_screen.dart';
import '../features/profile/screens/work_details_screen.dart';
import '../features/shell/nav_shell.dart';
import '../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authControllerProvider, (_, _) => refresh.bump());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.initializing) return null;
      final loc = state.matchedLocation;
      final authed = auth.isAuthenticated;
      const publicRoutes = {
        '/',
        '/login',
        '/forgot-password',
        '/forgot-password/otp',
        '/forgot-password/reset',
        '/signup/details',
        '/signup/otp',
        '/signup/password',
      };
      if (!authed && !publicRoutes.contains(loc) && loc != '/signup/roles') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/forgot-password/otp', builder: (_, _) => const ForgotPasswordOtpScreen()),
      GoRoute(path: '/forgot-password/reset', builder: (_, _) => const ForgotPasswordResetScreen()),
      GoRoute(path: '/signup/details', builder: (_, _) => const SignupDetailsScreen()),
      GoRoute(path: '/signup/otp', builder: (_, _) => const SignupOtpScreen()),
      GoRoute(path: '/signup/password', builder: (_, _) => const SignupPasswordScreen()),
      GoRoute(path: '/signup/roles', builder: (_, _) => const SignupRolesScreen()),
      ShellRoute(
        builder: (_, _, child) => NavShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          GoRoute(path: '/jobs', builder: (_, _) => const JobsScreen()),
          GoRoute(path: '/booking', builder: (_, _) => const BookingScreen()),
          GoRoute(path: '/directory', builder: (_, _) => const DirectoryScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileMenuScreen()),
        ],
      ),
      GoRoute(path: '/profile/personal', builder: (_, _) => const PersonalDetailsScreen()),
      GoRoute(path: '/profile/education', builder: (_, _) => const EducationScreen()),
      GoRoute(path: '/profile/work', builder: (_, _) => const WorkDetailsScreen()),
      GoRoute(path: '/profile/economic', builder: (_, _) => const EconomicDataScreen()),
      GoRoute(path: '/profile/bio', builder: (_, _) => const BioScreen()),
      GoRoute(path: '/profile/goals', builder: (_, _) => const GoalsScreen()),
      GoRoute(path: '/profile/verify-email', builder: (_, _) => const VerifyEmailScreen()),
      GoRoute(path: '/family', builder: (_, _) => const FamilyTreeHubScreen()),
      GoRoute(path: '/family/add', builder: (_, _) => const AddFamilyMemberScreen()),
      GoRoute(path: '/family/requests', builder: (_, _) => const FamilyRequestsScreen()),
      GoRoute(
        path: '/family/requests/:id',
        builder: (_, s) =>
            FamilyRequestDetailScreen(invitationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/feed/:id',
        builder: (_, s) =>
            PostDetailScreen(postId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/jobs/setup/role', builder: (_, _) => const JobRoleSelectionScreen()),
      GoRoute(path: '/jobs/setup/personal', builder: (_, _) => const JobPersonalInfoScreen()),
      GoRoute(path: '/jobs/setup/professional', builder: (_, _) => const JobProfessionalProfileScreen()),
      GoRoute(path: '/jobs/setup/cv', builder: (_, _) => const JobCvUploadScreen()),
      GoRoute(path: '/jobs/applied', builder: (_, _) => const AppliedJobsScreen()),
      GoRoute(path: '/jobs/saved', builder: (_, _) => const SavedJobsScreen()),
      GoRoute(
        path: '/jobs/:id',
        builder: (_, s) => JobDetailScreen(jobId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/jobs/:id/apply',
        builder: (_, s) => JobApplyScreen(jobId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/jobs/:id/applied/success',
        builder: (_, _) => const JobApplicationSubmittedScreen(),
      ),
      GoRoute(
        path: '/jobs/:id/applied/failed',
        builder: (_, s) => JobApplicationFailedScreen(
          company: s.uri.queryParameters['company'] ?? 'the company',
        ),
      ),
      GoRoute(
        path: '/booking/properties',
        builder: (_, _) => const PropertyListScreen(),
      ),
      GoRoute(
        path: '/booking/properties/:id',
        builder: (_, s) =>
            PropertyDetailScreen(propertyId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/properties/:id/checkout',
        builder: (_, s) =>
            BookingCheckoutScreen(propertyId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/properties/:id/payment',
        builder: (_, s) =>
            BookingPaymentScreen(propertyId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/confirmed/:bookingId',
        builder: (_, s) =>
            BookingConfirmedScreen(bookingId: s.pathParameters['bookingId']!),
      ),
      GoRoute(path: '/booking/my-bookings', builder: (_, _) => const MyBookingsScreen()),
      GoRoute(path: '/calendar', builder: (_, _) => const JainCalendarScreen()),
      GoRoute(path: '/location', builder: (_, _) => const JainLocationScreen()),
      GoRoute(
        path: '/location/:id',
        builder: (_, s) =>
            JainLocationDetailScreen(locationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/directory/:category',
        builder: (_, s) =>
            DirectoryListScreen(category: s.pathParameters['category']!),
      ),
      GoRoute(
        path: '/directory/members/:id',
        builder: (_, s) =>
            DirectoryMemberProfileScreen(memberId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/bookings/:id',
        builder: (_, s) =>
            BookingDetailScreen(bookingId: s.pathParameters['id']!),
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}
