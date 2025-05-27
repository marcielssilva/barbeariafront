import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dashboard_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final diaController = TextEditingController();
  final horarioController = TextEditingController();

  String _selectedServiceType = 'HAIRCUT';
  bool _isLoading = false;

  final Map<String, String> serviceOptions = {
    'Cabelo': 'HAIRCUT',
    'Barba': 'BEARD',
  };

  @override
  void dispose() {
    diaController.dispose();
    horarioController.dispose();
    super.dispose();
  }

  void _enviarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');

        if (token == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token não encontrado. Faça login.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final decodedToken = JwtDecoder.decode(token);
        final customerId = decodedToken['userId'];

        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        const String apiUrl = 'http://localhost:8080/api/appointments';

        final response = await dio.post(
          apiUrl,
          data: {
            'barberId': 'd8493d62-30e2-400d-827a-7e271011074e',
            'customerId': customerId,
            'date': DateFormat(
              'yyyy-MM-dd',
            ).format(DateFormat('dd/MM/yyyy').parse(diaController.text)),
            'startTime': horarioController.text,
            'serviceType': _selectedServiceType,
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agendamento realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao realizar agendamento. Código: ${response.statusCode}',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        String errorMessage = 'Erro ao realizar agendamento.';
        if (e is DioException) {
          if (e.response?.data != null &&
              e.response!.data['message'] is String) {
            errorMessage = e.response!.data['message'];
          } else if (e.message != null) {
            errorMessage = 'Erro de rede: ${e.message}';
          }
        } else {
          errorMessage = 'Erro desconhecido: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amberAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF3C4043),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF424242),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amberAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF3C4043),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF424242),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        horarioController.text = DateFormat('HH:mm').format(selectedDateTime);
      });
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, top: 20.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    );
  }

  // Modificado para aceitar prefixIcon
  InputDecoration _customInputDecoration(
    String label, {
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      hintText: hintText ?? 'Digite aqui...',
      // HintText padrão
      hintStyle: TextStyle(color: Colors.white38),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
      suffixIcon:
          suffixIcon != null ? Icon(suffixIcon, color: Colors.white70) : null,
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
        vertical: 16.0,
        horizontal: 12.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.dashboard_customize_outlined,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Meus Agendamentos',
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name !=
                  '/dashboard_customer') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardCustomerScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Você já está no painel de agendamentos."),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildSectionTitle(context, 'Data e Horário'),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: diaController,
                          style: TextStyle(color: Colors.white),
                          decoration: _customInputDecoration(
                            'Dia do Agendamento',
                            suffixIcon: Icons.calendar_today,
                            hintText: 'Toque para selecionar',
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Selecione o dia'
                                      : null,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _selectDate(context);
                          },
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: horarioController,
                          style: TextStyle(color: Colors.white),
                          decoration: _customInputDecoration(
                            'Horário do Agendamento',
                            suffixIcon: Icons.access_time,
                            hintText: 'Toque para selecionar',
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Selecione o horário'
                                      : null,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _selectTime(context);
                          },
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ),

                _buildSectionTitle(context, 'Serviço Desejado'),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedServiceType,
                      style: TextStyle(color: Colors.white),
                      dropdownColor: Color(0xFF3C4043),
                      decoration: _customInputDecoration(
                        'Tipo de Serviço',
                        prefixIcon: Icons.content_cut_outlined,
                      ).copyWith(hintText: 'Selecione o serviço'),
                      items:
                          serviceOptions.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.value,
                              child: Text(
                                entry.key,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedServiceType = value;
                          });
                        }
                      },
                      validator:
                          (value) =>
                              value == null ? 'Selecione um serviço' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _enviarAgendamento,
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
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 22),
                              SizedBox(width: 10),
                              Text('Confirmar Agendamento'),
                            ],
                          ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
