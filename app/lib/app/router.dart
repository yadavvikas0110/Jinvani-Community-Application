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
import '../features/booking/screens/booking_screen.dart';
import '../features/feed/screens/feed_screen.dart';
import '../features/feed/screens/post_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jobs/screens/jobs_screen.dart';
import '../features/profile/screens/bio_screen.dart';
import '../features/profile/screens/economic_data_screen.dart';
import '../features/profile/screens/education_screen.dart';
import '../features/profile/screens/goals_screen.dart';
import '../features/profile/screens/personal_details_screen.dart';
import '../features/profile/screens/profile_menu_screen.dart';
import '../features/profile/screens/work_details_screen.dart';
import '../features/shell/nav_shell.dart';
import '../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authControllerProvider, (_, __) => refresh.bump());
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
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/forgot-password/otp', builder: (_, __) => const ForgotPasswordOtpScreen()),
      GoRoute(path: '/forgot-password/reset', builder: (_, __) => const ForgotPasswordResetScreen()),
      GoRoute(path: '/signup/details', builder: (_, __) => const SignupDetailsScreen()),
      GoRoute(path: '/signup/otp', builder: (_, __) => const SignupOtpScreen()),
      GoRoute(path: '/signup/password', builder: (_, __) => const SignupPasswordScreen()),
      GoRoute(path: '/signup/roles', builder: (_, __) => const SignupRolesScreen()),
      ShellRoute(
        builder: (_, __, child) => NavShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/jobs', builder: (_, __) => const JobsScreen()),
          GoRoute(path: '/booking', builder: (_, __) => const BookingScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileMenuScreen()),
        ],
      ),
      GoRoute(path: '/profile/personal', builder: (_, __) => const PersonalDetailsScreen()),
      GoRoute(path: '/profile/education', builder: (_, __) => const EducationScreen()),
      GoRoute(path: '/profile/work', builder: (_, __) => const WorkDetailsScreen()),
      GoRoute(path: '/profile/economic', builder: (_, __) => const EconomicDataScreen()),
      GoRoute(path: '/profile/bio', builder: (_, __) => const BioScreen()),
      GoRoute(path: '/profile/goals', builder: (_, __) => const GoalsScreen()),
      GoRoute(path: '/family', builder: (_, __) => const FamilyTreeHubScreen()),
      GoRoute(path: '/family/add', builder: (_, __) => const AddFamilyMemberScreen()),
      GoRoute(path: '/family/requests', builder: (_, __) => const FamilyRequestsScreen()),
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
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}
