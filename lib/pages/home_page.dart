import 'package:flutter/material.dart';
import 'agendamento_page.dart';
 
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barbearia')),
      body: Center(
        child: ElevatedButton(
          child: Text('Agendar Atendimento'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AgendamentoPage()),
            );
          },
        ),
      ),
    );
  }
}