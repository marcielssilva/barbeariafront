import 'dart:convert';
import 'package:barbeariafront/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    print("Erro ao decodificar token ou pegar userId: $e");
    return null;
  }
}

String formatDateAndTime(String? day, String? startTime) {
  if (day == null || startTime == null) return 'Data/Hora inválida';
  try {
    final timeParts = startTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final dateParts = day.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final dayOfMonth = int.parse(dateParts[2]);

    final dateTime = DateTime(year, month, dayOfMonth, hour, minute);
    return DateFormat('dd/MM/yyyy – HH:mm').format(dateTime);
  } catch (e) {
    print("Erro ao formatar data e hora: $day, $startTime, Erro: $e");
    return 'Formato inválido';
  }
}

String formatServiceType(String? serviceType) {
  switch (serviceType) {
    case 'HAIRCUT':
      return 'Corte de Cabelo';
    case 'BEARD':
      return 'Barba';
    default:
      return serviceType ?? 'Não especificado';
  }
}

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  List<dynamic> confirmedAppointments = [];
  List<dynamic> pendingAppointments = [];
  bool _isLoading = true;
  String? _error;
  final Dio dio = ApiClient.dio;

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
      print("Token de acesso não encontrado em SharedPreferences.");
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
      const String apiUrl = 'http://localhost:8080/api/appointments';

      final response = await dio.get(apiUrl);

      if (mounted && response.data is List) {
        final allAppointments = List<dynamic>.from(response.data);
        setState(() {
          confirmedAppointments =
              allAppointments
                  .where((a) => a is Map && a['status'] == 'ACCEPTED')
                  .toList();
          pendingAppointments =
              allAppointments
                  .where((a) => a is Map && a['status'] == 'REQUESTED')
                  .toList();
        });
      } else if (mounted) {
        setState(() => _error = "Resposta inesperada da API.");
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['message'] as String? ??
          "Erro ao buscar agendamentos. Verifique a conexão.";
      print("DioException em _fetchAppointments: $e");
      setState(() => _error = msg);
    } catch (e) {
      if (!mounted) return;
      print("Erro genérico em _fetchAppointments: $e");
      setState(() => _error = "Erro ao buscar agendamentos: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmAppointment(String appointmentId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _setAuthHeader();
      const String baseUrl = 'http://localhost:8080/api/appointments';
      await dio.put('$baseUrl/$appointmentId/accept');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agendamento confirmado!"),
          backgroundColor: Colors.green,
        ),
      );
      _fetchAppointments();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['message'] as String? ??
          "Erro ao confirmar agendamento.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createWeeklyTimeslots() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _setAuthHeader();
      final barberId = await _getUserIdFromToken();
      if (barberId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ID do Barbeiro não encontrado no token."),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }
      const String baseUrl = 'http://localhost:8080/api/timeslots';
      await dio.post('$baseUrl/$barberId');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geração de agenda iniciada com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['message'] as String? ?? "Erro ao criar agenda.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao criar agenda: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAppointmentItem(
    Map<String, dynamic> appointment, {
    bool showConfirm = false,
  }) {
    final customerName =
        appointment['customerName']?.toString() ?? 'Nome não disponível';
    final serviceType = formatServiceType(
      appointment['serviceType']?.toString(),
    );
    final formattedDate = formatDateAndTime(
      appointment['day']?.toString(),
      appointment['startTime']?.toString(),
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color(0xFF2D3748).withOpacity(0.9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ),
        title: Text(
          "Cliente: $customerName",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "$formattedDate\nServiço: $serviceType",
          style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.4),
        ),
        isThreeLine: true,
        trailing:
            showConfirm
                ? ElevatedButton.icon(
                  onPressed:
                      () => _confirmAppointment(appointment['id'].toString()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.check_circle_outline, size: 18),
                  label: const Text("Confirmar"),
                )
                : null,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Color(0xFF1A202C),
        foregroundColor: Colors.white,
        elevation: 4.0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : _createWeeklyTimeslots,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: const Text(
                "Gerar Agenda",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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
        child:
            _isLoading &&
                    (confirmedAppointments.isEmpty &&
                        pendingAppointments.isEmpty)
                ? Center(
                  child: CircularProgressIndicator(color: Colors.amberAccent),
                )
                : _error != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.redAccent[100],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _fetchAppointments,
                  color: Colors.amberAccent,
                  backgroundColor: Color(0xFF2D3748),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSectionTitle(context, "Solicitações Pendentes"),
                      if (pendingAppointments.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "Nenhuma solicitação pendente no momento.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ...pendingAppointments.map(
                        (a) => _buildAppointmentItem(
                          a as Map<String, dynamic>,
                          showConfirm: true,
                        ),
                      ),

                      _buildSectionTitle(context, "Agendamentos Confirmados"),
                      if (confirmedAppointments.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "Nenhum agendamento confirmado.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ...confirmedAppointments.map(
                        (a) => _buildAppointmentItem(a as Map<String, dynamic>),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
