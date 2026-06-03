import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/user_role.dart';
import 'package:vanguard/core/providers/providers.dart';
import 'package:vanguard/core/providers/repository_providers.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';
import 'package:vanguard/core/repositories/firebase/firebase_auth_repository.dart';
import 'package:vanguard/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF080C18), Color(0xFF0E2355)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: -size.height * 0.1,
                  right: -size.width * 0.15,
                  child: _Orb(
                    size: size.width * 0.7,
                    color: const Color(0xFF4F46E5),
                    opacity: 0.10 +
                        0.03 * math.sin(_orbController.value * 2 * math.pi),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.45,
                  left: -size.width * 0.15,
                  child: _Orb(
                    size: size.width * 0.5,
                    color: const Color(0xFF1E3A8A),
                    opacity: 0.14 +
                        0.04 * math.cos(_orbController.value * 2 * math.pi),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          )
                              .animate()
                              .scale(
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                                begin: const Offset(0.5, 0.5),
                              )
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: 16),
                          const Text(
                            'VANGUARD',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 5,
                            ),
                          )
                              .animate(delay: 150.ms)
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: 0.2, end: 0, duration: 500.ms),
                          const SizedBox(height: 4),
                          Text(
                            'WORKFORCE MANAGEMENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.45),
                              letterSpacing: 3.5,
                            ),
                          ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF080C18),
                                letterSpacing: -0.5,
                              ),
                            )
                                .animate(delay: 200.ms)
                                .fadeIn(duration: 500.ms)
                                .slideX(begin: -0.1, end: 0),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to your workspace',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ).animate(delay: 280.ms).fadeIn(duration: 500.ms),
                            const SizedBox(height: 32),
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFCA5A5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .shake(duration: 400.ms),
                            _buildLabel('Email address'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: Color(0xFF0A0E1A),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              decoration: _inputDecoration(
                                hint: 'you@company.com',
                                icon: Icons.alternate_email_rounded,
                              ),
                              validator: (v) {
                                if (v?.isEmpty ?? true)
                                  return 'Enter your email';
                                if (!v!.contains('@'))
                                  return 'Enter a valid email';
                                return null;
                              },
                            )
                                .animate(delay: 350.ms)
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.15, end: 0),
                            const SizedBox(height: 20),
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                color: Color(0xFF0A0E1A),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v?.isEmpty ?? true)
                                  return 'Enter your password';
                                if (v!.length < 6)
                                  return 'Minimum 6 characters';
                                return null;
                              },
                            )
                                .animate(delay: 430.ms)
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.15, end: 0),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF4F46E5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  gradient: _isLoading
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF6B7280),
                                            Color(0xFF4B5563)
                                          ],
                                        )
                                      : const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFF4F46E5),
                                            Color(0xFF7C3AED)
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: _isLoading
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: const Color(0xFF4F46E5)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            )
                                .animate(delay: 550.ms)
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 32),
                            Center(
                              child: Text(
                                '© 2025 Vanguard by Gentleways',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ).animate(delay: 700.ms).fadeIn(duration: 500.ms),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: 100.ms).slideY(
                        begin: 0.06,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
        letterSpacing: 0.2,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(authViewModelProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!success) {
        setState(() {
          _errorMessage = ref.read(authViewModelProvider).error ??
              'Invalid email or password.';
          _isLoading = false;
        });
        return;
      }

      final user = ref.read(authViewModelProvider).user;
      if (user == null) {
        setState(() {
          _errorMessage =
              'User profile not found. Please contact your administrator.';
          _isLoading = false;
        });
        return;
      }

      if (!user.isActive) {
        setState(() {
          _errorMessage =
              'Your account has been deactivated. Please contact your administrator.';
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      if (user.role == UserRole.admin) {
        final authRepo = ref.read(authRepositoryProvider);
        if (authRepo is FirebaseAuthRepository) {
          authRepo.setAdminCredentials(
            _emailController.text.trim(),
            _passwordController.text,
          );
        }
      }

      switch (user.role) {
        case UserRole.admin:
          context.go('/admin-dashboard');
          break;
        case UserRole.secretary:
          context.go('/secretary-dashboard');
          break;
        case UserRole.employee:
          context.go('/employee-dashboard');
          break;
        case UserRole.volunteer:
          context.go('/volunteer-dashboard');
          break;
      }
    } catch (e) {
      String message = 'An error occurred. Please try again.';
      final err = e.toString().toLowerCase();
      if (err.contains('user-not-found') ||
          err.contains('wrong-password') ||
          err.contains('invalid-credential')) {
        message = 'Invalid email or password.';
      } else if (err.contains('user-disabled')) {
        message = 'This account has been disabled.';
      } else if (err.contains('network')) {
        message = 'Network error. Please check your connection.';
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email address first')),
      );
      return;
    }
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send reset email. Try again.')),
      );
    }
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0)
          ],
        ),
      ),
    );
  }
}
