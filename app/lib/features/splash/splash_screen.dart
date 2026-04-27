import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/state/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  DateTime? _start;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    // Force the auth provider to instantiate and kick off bootstrap immediately.
    ref.read(authControllerProvider);
  }

  void _maybeNavigate(AuthState state) {
    if (_navigated || !mounted) return;
    if (state.initializing) return;
    final elapsed = DateTime.now().difference(_start!);
    const minSplash = Duration(milliseconds: 1200);
    final wait = elapsed < minSplash ? minSplash - elapsed : Duration.zero;
    _navigated = true;
    Future.delayed(wait, () {
      if (!mounted) return;
      context.go(state.isAuthenticated ? '/home' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (_, next) => _maybeNavigate(next));
    // Cover cold-start where auth resolved before the listener attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeNavigate(ref.read(authControllerProvider));
    });
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/logo.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
