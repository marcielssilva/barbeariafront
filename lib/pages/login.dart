import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'agendamento_page.dart';
import 'dashboard_admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }

    final payload = base64Url.normalize(parts[1]);
    final payloadMap =
    json.decode(utf8.decode(base64Url.decode(payload)));

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Payload inválido');
    }

    return payloadMap;
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Preencha todos os campos.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8080/api/auth/login', // Use actual IP if on real device
        data: {
          "email": email,
          "password": password,
        },
      );

      final token = response.data['accessToken'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token);

      final decoded = parseJwt(token);
      final roleRaw = decoded['roles'];
      if (roleRaw == null) {
        setState(() => _error = "Tipo de usuário desconhecido (roles ausente).");
        return;
      }

      final role = roleRaw.toString().toLowerCase();

      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AgendamentoPage()),
        );
      } else if (role == 'barber') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardAdminScreen()),
        );
      } else {
        setState(() => _error = "Tipo de usuário desconhecido.");
      }
    } on DioError catch (e) {
      final msg = e.response?.data['message'] ?? "Erro ao fazer login.";
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = "Erro: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Entrar"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
