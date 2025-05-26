import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
  bool _isPasswordVisible = false;

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }
    final payload = base64Url.normalize(parts[1]);
    final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Payload inválido');
    }
    return payloadMap;
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Preencha o email e a senha.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = Dio();
      const String apiUrl = 'http://localhost:8080/api/auth/login';

      final response = await dio.post(
        apiUrl,
        data: {"email": email, "password": password},
      );

      final token = response.data['accessToken'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token);

      final decoded = parseJwt(token);
      dynamic rolesClaim = decoded['roles'];
      String role = '';

      if (rolesClaim is List && rolesClaim.isNotEmpty) {
        role = rolesClaim[0].toString().toLowerCase();
      } else if (rolesClaim is String) {
        role = rolesClaim.toString().toLowerCase();
      } else {
        if (!mounted) return;
        setState(
          () =>
              _error =
                  "Tipo de usuário desconhecido (roles ausente ou formato inválido).",
        );
        return;
      }

      if (!mounted) return;
      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AgendamentoPage()),
        );
      } else if (role == 'barber' || role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardAdminScreen()),
        );
      } else {
        setState(() => _error = "Tipo de usuário '$role' não reconhecido.");
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data['message'] as String? ??
          "Erro ao fazer login. Verifique suas credenciais ou a conexão com o servidor.";
      setState(() => _error = msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Erro inesperado: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _customInputDecoration(
    String label, {
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      hintText: hintText ?? label,
      hintStyle: TextStyle(color: Colors.white38),
      prefixIcon: Icon(prefixIcon, color: Colors.white70, size: 20),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.25),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18.0,
        horizontal: 12.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xFF1F2937).withOpacity(0.85),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bem-vindo!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Faça login para continuar',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: _customInputDecoration(
                        "Email",
                        prefixIcon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.white),
                      decoration: _customInputDecoration(
                        "Senha",
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    const SizedBox(height: 12),
                    if (_error != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 0),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.redAccent[100],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.amberAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black87,
                                    strokeWidth: 3,
                                  ),
                                )
                                : const Text("Entrar"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
