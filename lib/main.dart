import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'pages/agendamento_page.dart';
import 'pages/dashboard_admin.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.configure();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length != 3) throw Exception("Token inválido");

        final payload =
        json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
        final expiry = payload['exp'];
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        if (expiry != null && expiry < now) {
          await prefs.remove('accessToken');
          return const HomePage();
        }

        final role = (payload['roles'] as List).first.toLowerCase();

        if (role == 'barber') return const DashboardAdminScreen();
        if (role == 'customer') return const AgendamentoPage();
      } catch (_) {
        await prefs.remove('accessToken');
      }
    }

    return const HomePage(); // fallback
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbearia App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}