import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanguard/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _shimmerController;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showContent = true);
    });

    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('onboarding_completed') ?? false;
    if (!mounted) return;
    if (hasCompletedOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF080C18),
                  Color(0xFF0E2355),
                  Color(0xFF1A1F5E),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              final size = MediaQuery.of(context).size;
              return Stack(
                children: [
                  Positioned(
                    top: -size.height * 0.15,
                    right: -size.width * 0.25,
                    child: _GlowOrb(
                      size: size.width * 0.8,
                      color: const Color(0xFF4F46E5),
                      opacity: 0.12 +
                          0.04 * math.sin(_orbController.value * 2 * math.pi),
                    ),
                  ),
                  Positioned(
                    bottom: -size.height * 0.1,
                    left: -size.width * 0.2,
                    child: _GlowOrb(
                      size: size.width * 0.65,
                      color: const Color(0xFF1E3A8A),
                      opacity: 0.18 +
                          0.05 *
                              math.sin(
                                  _orbController.value * 2 * math.pi + 1.5),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.38,
                    left: size.width * 0.5,
                    child: _GlowOrb(
                      size: size.width * 0.4,
                      color: const Color(0xFF6366F1),
                      opacity: 0.08 +
                          0.03 * math.cos(_orbController.value * 2 * math.pi),
                    ),
                  ),
                ],
              );
            },
          ),
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter(),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                if (_showContent)
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5)
                                    .withValues(alpha: 0.45),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 52,
                          ),
                        )
                            .animate()
                            .scale(
                              duration: 700.ms,
                              curve: Curves.elasticOut,
                              begin: const Offset(0.4, 0.4),
                              end: const Offset(1.0, 1.0),
                            )
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 32),
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: const [
                                    Colors.white,
                                    Color(0xFFEAB308),
                                    Colors.white,
                                  ],
                                  stops: [
                                    (_shimmerController.value - 0.3)
                                        .clamp(0.0, 1.0),
                                    _shimmerController.value,
                                    (_shimmerController.value + 0.3)
                                        .clamp(0.0, 1.0),
                                  ],
                                ).createShader(bounds);
                              },
                              child: child!,
                            );
                          },
                          child: const Text(
                            'VANGUARD',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                        )
                            .animate(delay: 300.ms)
                            .slideY(
                              duration: 600.ms,
                              begin: 0.3,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            )
                            .fadeIn(duration: 500.ms),
                        const SizedBox(height: 10),
                        Text(
                          'WORKFORCE MANAGEMENT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                            letterSpacing: 4,
                          ),
                        )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(
                              duration: 500.ms,
                              begin: 0.2,
                              end: 0,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 28),
                        Container(
                          width: 48,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEAB308), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        )
                            .animate(delay: 700.ms)
                            .scaleX(
                              duration: 500.ms,
                              begin: 0,
                              end: 1,
                              curve: Curves.easeOut,
                            )
                            .fadeIn(duration: 300.ms),
                      ],
                    ),
                  ),
                const Spacer(flex: 3),
                if (_showContent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 56),
                    child: Column(
                      children: [
                        _AnimatedDotLoader()
                            .animate(delay: 900.ms)
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),
                        Text(
                          'Preparing your workspace...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.40),
                            letterSpacing: 0.5,
                          ),
                        ).animate(delay: 1100.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

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
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDotLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(3),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(
              delay: (i * 200).ms,
              duration: 600.ms,
              begin: 0.5,
              end: 1.0,
              curve: Curves.easeInOut,
            )
            .fadeIn(
              delay: (i * 200).ms,
              duration: 600.ms,
            );
      }),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
