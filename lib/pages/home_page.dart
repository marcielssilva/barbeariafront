import 'package:flutter/material.dart';
import 'agendamento_page.dart';
import '../screens/client_registration_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Barbearia',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 4,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/barbershop_img.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bem-vindo à Barbearia',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Agendar Atendimento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AgendamentoPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Cadastrar Cliente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientRegistrationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
