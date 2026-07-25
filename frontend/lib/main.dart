import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/send/screens/send_transfer_screen.dart';
import 'core/services/security_service.dart';


import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint(
      'ERROR: Supabase credentials not found.\n'
      'Collaborators: Please copy .env.example to .env and run via VS Code,\n'
      'or use: flutter run --dart-define-from-file=.env',
    );
    // In a production scenario, you would navigate to a configuration error screen here.
    return; 
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize security service (loads persisted attempts)
  await SecurityService.instance.initialize();

  // Always start fresh — clear any stored session on app launch
  // User must authenticate via login screen every time the app starts
  await AuthProvider.instance.clearSession();

  runApp(
    ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: const WealthWiseApp(initialRoute: '/login'),
    ),
  );
}

class WealthWiseApp extends StatelessWidget {
  final String initialRoute;
  const WealthWiseApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => SecurityService.instance.resetInactivityTimer(),
      onPointerMove: (_) => SecurityService.instance.resetInactivityTimer(),
      child: MaterialApp(
        navigatorKey: SecurityService.instance.navigatorKey,
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        showSemanticsDebugger: false,
        debugShowMaterialGrid: false,
        checkerboardRasterCacheImages: false,
        checkerboardOffscreenLayers: false,
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            // Ensure timer starts on home screen
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
