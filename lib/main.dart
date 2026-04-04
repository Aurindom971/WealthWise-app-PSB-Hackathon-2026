import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kbyfljxmbzzgowautqyb.supabase.co',
    anonKey: 'sb_publishable_GZdb1XwqNJ8hPiTscRueRg_rF5uhWoI',
  );

  runApp(const SecureWealthApp());
}

class SecureWealthApp extends StatelessWidget {
  const SecureWealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
