import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'agendamento_page.dart';

class DashboardCustomerScreen extends StatefulWidget {
  const DashboardCustomerScreen({super.key});

  @override
  State<DashboardCustomerScreen> createState() =>
      _DashboardCustomerScreenState();
}

Future<String?> _getUserIdFromToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) return null;
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final Map<String, dynamic> payloadMap = json.decode(payload);
    return payloadMap['userId']?.toString();
  } catch (e) {
    return null;
  }
}

String formatDateAndTime(String? day, String? startTime) {
  if (day == null || startTime == null) return 'Data/Hora inválida';
  try {
    final timeParts = startTime.split(':');
    if (timeParts.length < 2) return 'Formato de hora inválido';
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final dateParts = day.split('-');
    if (dateParts.length < 3) return 'Formato de data inválido';
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final dayOfMonth = int.parse(dateParts[2]);

    final dateTime = DateTime(year, month, dayOfMonth, hour, minute);
    return DateFormat('dd/MM/yyyy – HH:mm', 'pt_BR').format(dateTime);
  } catch (e) {
    return 'Data/Hora em formato inválido';
  }
}

String formatServiceType(String? serviceType) {
  switch (serviceType?.toUpperCase()) {
    case 'HAIRCUT':
      return 'Corte de Cabelo';
    case 'BEARD':
      return 'Barba';
    default:
      return serviceType ?? 'Não especificado';
  }
}

class _DashboardCustomerScreenState extends State<DashboardCustomerScreen> {
  List<dynamic> appointments = [];
  bool _isLoading = true;
  String? _error;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _setAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      if (mounted) {
        setState(() {
          _error = "Sessão expirada. Por favor, faça login novamente.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _setAuthHeader();
      if (dio.options.headers['Authorization'] == null) {
        return;
      }

      final userId = await _getUserIdFromToken();
      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _error = "Usuário não autenticado.";
          _isLoading = false;
        });
        return;
      }
      const String apiUrl = 'http://localhost:8080/api/appointments';

      final response = await dio.get(
        apiUrl,
        queryParameters: {'customerId': userId},
      );

      if (!mounted) return;
      if (response.data is List) {
        setState(() {
          appointments = List<dynamic>.from(response.data);
        });
      } else {
        setState(() => _error = "Resposta inesperada da API.");
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['message'] as String? ??
          "Erro de rede ao buscar agendamentos.";
      setState(() => _error = msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Erro ao buscar agendamentos: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    final barberName =
        appointment['barberName']?.toString() ?? 'Barbeiro não disponível';
    final formattedDate = formatDateAndTime(
      appointment['day']?.toString(),
      appointment['startTime']?.toString(),
    );
    final serviceType = formatServiceType(
      appointment['serviceType']?.toString(),
    );

    String statusDisplay = 'Desconhecido';
    Color statusColor = Colors.grey[500]!;
    IconData statusIcon = Icons.help_outline;

    switch (appointment['status']?.toString().toUpperCase()) {
      case 'REQUESTED':
        statusDisplay = 'Pendente';
        statusColor = Colors.orangeAccent[200]!;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case 'ACCEPTED':
        statusDisplay = 'Confirmado';
        statusColor = Colors.greenAccent[400]!;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'CANCELLED':
        statusDisplay = 'Cancelado';
        statusColor = Colors.redAccent[100]!;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'COMPLETED':
        statusDisplay = 'Concluído';
        statusColor = Colors.blueAccent[100]!;
        statusIcon = Icons.done_all_rounded;
        break;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2D3748),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Barbeiro: $barberName",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.content_cut_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Serviço: $serviceType",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Status: $statusDisplay",
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cores do tema escuro
    const Color darkBgStart = Color(0xFF2D3748);
    const Color darkBgEnd = Color(0xFF1A202C);
    const Color appBarColor = Color(0xFF1F2937);
    const Color accentColor = Colors.amberAccent;
    const Color textColor = Colors.white;
    final Color subTextColor = Colors.white.withOpacity(0.85);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Agendamentos"),
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        elevation: 3.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkBgStart, darkBgEnd],
          ),
        ),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : _error != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.redAccent[100],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _fetchAppointments,
                  color: accentColor,
                  backgroundColor: darkBgStart,
                  child:
                      appointments.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  size: 60,
                                  color: subTextColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Nenhum agendamento encontrado.",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: subTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.black87,
                                  ),
                                  label: const Text(
                                    'Agendar Novo Horário',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AgendamentoPage(),
                                      ),
                                    ).then((_) => _fetchAppointments());
                                  },
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
                            itemCount: appointments.length,
                            itemBuilder: (context, index) {
                              return _buildAppointmentItem(
                                appointments[index] as Map<String, dynamic>,
                              );
                            },
                          ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgendamentoPage()),
          ).then((_) {
            _fetchAppointments();
          });
        },
        label: const Text(
          'Agendar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        icon: const Icon(Icons.add, color: Colors.black87),
        backgroundColor: accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
