import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'admin_page.dart';
import 'chat_page.dart';
import 'device_dashboard.dart';
import 'landing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tr4sVortex',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'ShareTechMono',
        scaffoldBackgroundColor: const Color(0xFF120000),
        colorScheme: ColorScheme.dark().copyWith(
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFFFF5252),
          surface: const Color(0xFF2A0000),
        ),
      ),
      initialRoute: '/', // ← UBAH ke '/' agar LandingPage yang pertama muncul
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/': // ← TAMBAHKAN route untuk LandingPage
            return MaterialPageRoute(builder: (_) => const LandingPage());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DashboardPage(
                username: args['username'],
                password: args['password'],
                role: (args['role'] ?? '').toString(),
                sessionKey: args['key'],
                expiredDate: args['expiredDate'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                listDoos: List<Map<String, dynamic>>.from(args['listDoos'] ?? []),
                news: List<Map<String, dynamic>>.from(args['news'] ?? []),
              ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => HomePage(
                username: args['username'],
                password: args['password'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                role: (args['role'] ?? '').toString(),
                expiredDate: args['expiredDate'],
                sessionKey: args['sessionKey'],
              ),
            );

          case '/seller':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SellerPage(
                keyToken: args['keyToken'],
              ),
            );

          case '/admin':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AdminPage(
                sessionKey: args['sessionKey'],
              ),
            );

          case '/chat':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ChatPage(
                currentUsername: args?['username'] ?? 'User',
                sessionKey: args?['sessionKey'] ?? '',
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "404 - Halaman Tidak Ditemukan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}