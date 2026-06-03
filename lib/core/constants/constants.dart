import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static const double card = lg;
  static const double button = md;
  static const double input = md;
  static const double chip = sm;
  static const double avatar = full;
}

class AppColors {
  const AppColors._();

  static const Color midnight = Color(0xFF080C18);

  static const Color primary = Color(0xFF0E2355);

  static const Color secondary = Color(0xFF4F46E5);

  static const Color gold = Color(0xFFEAB308);

  static const Color accent = Color(0xFF6366F1);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF4B5563);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color primaryDark = Color(0xFF818CF8);
  static const Color backgroundDark = Color(0xFF070B15);
  static const Color surfaceDark = Color(0xFF0E1628);
  static const Color cardDark = Color(0xFF132038);
  static const Color onSurfaceVariantDark = Color(0xFF8B9CC8);

  static const Color adminColor = Color(0xFF4F46E5);
  static const Color secretaryColor = Color(0xFF0EA5E9);
  static const Color employeeColor = Color(0xFF10B981);
  static const Color volunteerColor = Color(0xFFF59E0B);
}

class AppGradients {
  const AppGradients._();

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF080C18), Color(0xFF0E2355), Color(0xFF1E3A8A)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E2355), Color(0xFF4F46E5)],
  );

  static const LinearGradient indigo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAB308), Color(0xFFD97706)],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const LinearGradient admin = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
  );

  static const LinearGradient secretary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
  );
}

class AppElevation {
  const AppElevation._();

  static const double none = 0.0;
  static const double low = 1.0;
  static const double medium = 2.0;
  static const double high = 4.0;
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF080C18).withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF080C18).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF080C18).withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF080C18).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF080C18).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get indigo => [
        BoxShadow(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> colored(Color color, {double opacity = 0.25}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
}

class AppCurrency {
  const AppCurrency._();

  static String format(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
  static const Duration stagger = Duration(milliseconds: 80);
}

class AppCurves {
  const AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutExpo;
  static const Curve decelerate = Curves.decelerate;
  static const Curve spring = Curves.elasticOut;
  static const Curve sharp = Curves.easeInOutCubic;
}
