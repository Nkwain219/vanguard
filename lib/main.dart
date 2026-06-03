import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firestore_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/offline_attendance_service.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    await _initializeApp();
  }, (error, stack) {
    debugPrint('❌ Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  try {
    await dotenv.load(fileName: '.env');
    print('✓ Environment variables loaded');
  } catch (e) {
    print('⚠ Warning: Could not load .env file: $e');
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✓ Firebase initialized');
    } else {
      print('✓ Firebase already initialized');
    }
  } catch (e) {
    print('✗ Firebase initialization failed: $e');
  }

  try {
    await FirestoreService.initialize();
    print('✓ Firestore initialized');
  } catch (e) {
    print('✗ Firestore initialization failed: $e');
  }

  try {
    await PushNotificationService.instance.initialize();
    print('✓ Push notifications initialized');
  } catch (e) {
    debugPrint('⚠ Push notifications not available: $e');
  }

  try {
    await OfflineAttendanceService.instance.initialize();
    print('✓ Offline storage initialized');
  } catch (e) {
    print('✗ Offline storage initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: VanguardApp(),
    ),
  );
}

class VanguardApp extends ConsumerWidget {
  const VanguardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Vanguard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      routerConfig: router,
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details.exception.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
