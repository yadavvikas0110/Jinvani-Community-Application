import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../data/auth_repository.dart';
import '../data/google_auth_service.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _SocialButton extends StatelessWidget {
  final String? asset;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _SocialButton({
    required this.asset,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: asset != null 
            ? SvgPicture.asset(asset!, width: 24, height: 24)
            : Icon(icon, size: 28, color: iconColor),
      ),
    );
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _googleLogin() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final googleService = ref.read(googleAuthServiceProvider);
      final idToken = await googleService.signIn();
      
      if (idToken == null) {
        // User cancelled login
        setState(() => _loading = false);
        return;
      }

      await ref.read(authControllerProvider.notifier).loginWithGoogle(idToken);
      if (mounted) context.go('/home');
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.response?.data['error']?['message'] ?? 'Google login failed';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred with Google login';
          _loading = false;
        });
      }
    }
  }

  void _socialStub(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in coming soon')),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).login(
            identifier: _id.text.trim(),
            password: _pw.text,
          );
      ref.read(authControllerProvider.notifier).setUser(user);
      if (mounted) context.go('/home');
    } on DioException catch (e) {
      debugPrint('[login] DioException type=${e.type} code=${e.response?.statusCode} body=${e.response?.data} msg=${e.message}');
      final code = e.response?.statusCode;
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] as String?)
          : null;
      setState(() {
        if (code == 401 || code == 403) {
          _error = serverMsg ?? 'Invalid credentials';
        } else if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          _error = "Can't reach server — is the API running?";
        } else {
          _error = serverMsg ?? 'Login failed (${code ?? e.type.name})';
        }
      });
    } catch (e, st) {
      debugPrint('[login] non-dio exception: $e\n$st');
      setState(() => _error = 'Login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2A66),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/splash/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Jinvani Community',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome Back',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Login to continue', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    const Text('Email or Mobile', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _id,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.textMuted),
                        hintText: 'priya@example.com',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Password', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pw,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Forgot Password?',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    const SizedBox(height: 8),
                    GradientButton(
                      label: 'Continue',
                      trailingIcon: Icons.arrow_forward,
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue with',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          asset: 'assets/icons/common/google_g.svg',
                          icon: Icons.g_mobiledata,
                          iconColor: const Color(0xFFDB4437),
                          onTap: _googleLogin,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          asset: null,
                          icon: Icons.apple,
                          iconColor: Colors.black,
                          onTap: () => _socialStub('Apple'),
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          asset: null,
                          icon: Icons.facebook,
                          iconColor: const Color(0xFF1877F2),
                          onTap: () => _socialStub('Facebook'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Didn't have an account? ",
                              style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.go('/signup/details'),
                            child: const Text('Sign Up',
                                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
