import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/send/screens/send_transfer_screen.dart';
import 'core/services/security_service.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder.supabase.co');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'placeholder_key');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Warning: Supabase initialization skipped or failed: $e');
    }
  } else {
    debugPrint('Notice: Running without active Supabase credentials.');
  }

  // Initialize security service (loads persisted attempts)
  await SecurityService.instance.initialize();

  // Initialize language provider (loads saved language)
  await LanguageProvider.instance.initialize();

  // Always start fresh — clear any stored session on app launch
  await AuthProvider.instance.clearSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider.instance),
        ChangeNotifierProvider<LanguageProvider>.value(value: LanguageProvider.instance),
      ],
      child: const WealthWiseApp(initialRoute: '/login'),
    ),
  );
}

class WealthWiseApp extends StatelessWidget {
  final String initialRoute;
  const WealthWiseApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Listener(
      onPointerDown: (_) => SecurityService.instance.resetInactivityTimer(),
      onPointerMove: (_) => SecurityService.instance.resetInactivityTimer(),
      child: MaterialApp(
        navigatorKey: SecurityService.instance.navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: languageProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('pa'),
        ],
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            SecurityService.instance.resetInactivityTimer();
            return HomeScreen(initialIndex: args?['index'] as int?);
          },
          '/send_transfer': (context) => const SendTransferScreen(),
          '/qr_scanner': (context) => const QRScreen(),
        },
      ),
    );
  }
}

