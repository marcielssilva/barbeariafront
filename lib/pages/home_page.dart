import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'client_registration.dart';
import 'dashboard_customer.dart';
import 'agendamento_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCustomerLoggedIn = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndRole();
  }

  Future<void> _checkLoginStatusAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      if (mounted) {
        setState(() {
          _isCustomerLoggedIn = false;
          _userName = '';
        });
      }
      return;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        if (mounted) setState(() => _isCustomerLoggedIn = false);
        return;
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final Map<String, dynamic> payloadMap = json.decode(payload);
      dynamic rolesClaim = payloadMap['roles'];
      String role = '';
      String nameFromToken = payloadMap['user'] ?? 'Cliente';
      if (rolesClaim is List && rolesClaim.isNotEmpty) {
        role = rolesClaim[0].toString().toLowerCase();
      } else if (rolesClaim is String) {
        role = rolesClaim.toString().toLowerCase();
      }

      if (mounted) {
        setState(() {
          _isCustomerLoggedIn = (role == 'customer');
          if (_isCustomerLoggedIn) {
            _userName = nameFromToken;
          } else {
            _userName = '';
          }
        });
      }
    } catch (e) {
      await prefs.remove('accessToken');
      if (mounted) {
        setState(() {
          _isCustomerLoggedIn = false;
          _userName = '';
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    if (mounted) {
      _checkLoginStatusAndRole();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.amberAccent,
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    );

    final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.15),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      elevation: 2,
    );

    final ButtonStyle logoutButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isCustomerLoggedIn ? 'Olá, $_userName' : 'Barbearia',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: _isCustomerLoggedIn ? 22 : 26,
            color: Colors.white,
            shadows: const [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        actions: [
          if (_isCustomerLoggedIn)
            IconButton(
              icon: const Icon(
                Icons.dashboard_customize_outlined,
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Meus Agendamentos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardCustomerScreen(),
                  ),
                ).then((_) => _checkLoginStatusAndRole());
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/barbershop_img.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.70)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isCustomerLoggedIn) ...[
                    Text(
                      'Bem-vindo à Barbearia',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Estilo e precisão em cada corte.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.85),
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      'O que deseja fazer hoje?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 40),

                  if (_isCustomerLoggedIn) ...[
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                      ),
                      label: const Text('Novo Agendamento'),
                      style: primaryButtonStyle,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgendamentoPage(),
                          ),
                        );
                        _checkLoginStatusAndRole();
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.list_alt_outlined, size: 20),
                      label: const Text('Meus Agendamentos'),
                      style: secondaryButtonStyle,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardCustomerScreen(),
                          ),
                        );
                        _checkLoginStatusAndRole();
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout_outlined, size: 20),
                      label: const Text('Sair'),
                      style: logoutButtonStyle,
                      onPressed: _logout,
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text('Fazer Login'),
                      style: primaryButtonStyle,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                        _checkLoginStatusAndRole();
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 20,
                      ),
                      label: const Text('Criar Conta'),
                      style: secondaryButtonStyle,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClientRegistrationScreen(),
                          ),
                        );
                        _checkLoginStatusAndRole();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
