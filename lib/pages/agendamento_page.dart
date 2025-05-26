import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final contatoController = TextEditingController();
  final diaController = TextEditingController();
  final horarioController = TextEditingController();

  String _selectedServiceType = 'HAIRCUT';

  final Map<String, String> serviceOptions = {
    'Cabelo': 'HAIRCUT',
    'Barba': 'BEARD',
  };

  void _enviarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token não encontrado. Faça login.')),
          );
          return;
        }

        final decodedToken = JwtDecoder.decode(token);
        final customerId = decodedToken['userId']; // Must match claim name in your backend

        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        final response = await dio.post(
          'http://localhost:8080/api/appointments',
          data: {
            'barberId': 'a04027e0-cf42-4a6e-ad5d-df00fc3ea73a',
            'customerId': customerId,
            'date': DateFormat('yyyy-MM-dd').format(
              DateFormat('dd/MM/yyyy').parse(diaController.text),
            ),
            'startTime': horarioController.text,
            'serviceType': _selectedServiceType,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
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
                DropdownButtonFormField<String>(
                  value: _selectedServiceType,
                  decoration: InputDecoration(
                    labelText: 'Serviço',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: serviceOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedServiceType = value!;
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _enviarAgendamento,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
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
