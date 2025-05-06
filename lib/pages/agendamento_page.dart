import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
 
class AgendamentoPage extends StatefulWidget {
  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}
 
class _AgendamentoPageState extends State<AgendamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final contatoController = TextEditingController();
  final diaController = TextEditingController();
  final horarioController = TextEditingController();
 
  void _enviarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dio = Dio();
        final response = await dio.post(
          'http://10.0.2.2:8080/agendamentos',
          data: {
            'nome': nomeController.text,
            'contato': contatoController.text,
            'dia': diaController.text,
            'horario': horarioController.text,
          },
        );
 
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Agendamento realizado com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao realizar agendamento.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Digite o nome' : null,
              ),
              TextFormField(
                controller: contatoController,
                decoration: InputDecoration(labelText: 'WhatsApp'),
                validator: (value) => value!.isEmpty ? 'Digite o número' : null,
              ),
              TextFormField(
                controller: diaController,
                decoration: InputDecoration(labelText: 'Dia (dd/mm/aaaa)'),
                validator: (value) => value!.isEmpty ? 'Digite o dia' : null,
              ),
              TextFormField(
                controller: horarioController,
                decoration: InputDecoration(labelText: 'Horário (hh:mm)'),
                validator: (value) => value!.isEmpty ? 'Digite o horário' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviarAgendamento,
                child: Text('Confirmar Agendamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}