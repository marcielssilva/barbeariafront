import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Para formatação de data/hora

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  // Função para selecionar e formatar a data
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        diaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Função para selecionar e formatar o horário
  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        horarioController.text = DateFormat('HH:mm').format(selectedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value!.isEmpty ? 'Digite o nome' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: contatoController,
                  decoration: InputDecoration(
                    labelText: 'WhatsApp',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Digite o número' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: diaController,
                  decoration: InputDecoration(
                    labelText: 'Dia (dd/mm/aaaa)',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value!.isEmpty ? 'Digite o dia' : null,
                  onTap: () => _selectDate(context),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: horarioController,
                  decoration: InputDecoration(
                    labelText: 'Horário (hh:mm)',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Digite o horário' : null,
                  onTap: () => _selectTime(context),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _enviarAgendamento,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    textStyle: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirmar Agendamento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
