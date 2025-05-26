import 'dart:convert';

import 'package:barbeariafront/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

// Função pra pegar o barberId do token
Future<String?> _getUserIdFromToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) return null;

  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> payloadMap = json.decode(payload);

    return payloadMap['userId']?.toString();
  } catch (e) {
    return null;
  }
}

// Função para formatar data + hora juntando day e startTime
String formatDateAndTime(String? day, String? startTime) {
  if (day == null || startTime == null) return 'Data inválida';

  try {
    final dateTime = DateTime.parse('$day $startTime');
    return DateFormat('dd/MM/yyyy – HH:mm').format(dateTime);
  } catch (e) {
    return 'Data inválida';
  }
}

String formatServiceType(String? serviceType) {
  switch (serviceType) {
    case 'HAIRCUT':
      return 'Corte';
    case 'BEARD':
      return 'Barba';
    default:
      return serviceType ?? 'Serviço não especificado';
  }
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
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _setAuthHeader();

      final response = await dio.get('http://localhost:8080/api/appointments');

      setState(() {
        // Aqui você pode separar confirmados e pendentes conforme o status
        confirmedAppointments = response.data
            .where((a) => a['status'] == 'ACCEPTED')
            .toList();
        pendingAppointments = response.data
            .where((a) => a['status'] == 'REQUESTED')
            .toList();
      });
    } catch (e) {
      setState(() => _error = "Erro ao buscar agendamentos: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAppointment(String appointmentId) async {
    try {
      await _setAuthHeader();

      await dio.put('http://localhost:8080/api/appointments/$appointmentId/accept');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento confirmado!")),
      );
      _fetchAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${e.toString()}")),
      );
    }
  }

  Future<void> _createWeeklyTimeslots() async {
    try {
      await _setAuthHeader();

      final barberId = await _getUserIdFromToken();
      if (barberId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Barber ID não encontrado no token.")),
        );
        return;
      }

      await dio.post('http://localhost:8080/api/timeslots/$barberId');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agenda semanal criada com sucesso!")),
      );

      _fetchAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar agenda: ${e.toString()}")),
      );
    }
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment, {bool showConfirm = false}) {
    final customerName = appointment['customerName']?.toString() ?? 'Nome não disponível';

    // usa a função para traduzir o serviceType
    final serviceType = formatServiceType(appointment['serviceType']?.toString());

    final formattedDate = formatDateAndTime(appointment['day'], appointment['startTime']);

    return Card(
      child: ListTile(
        title: Text("Cliente: $customerName"),
        subtitle: Text("$formattedDate\nServiço: $serviceType"),
        isThreeLine: true,
        trailing: showConfirm
            ? ElevatedButton(
          onPressed: () => _confirmAppointment(appointment['id']),
          child: const Text("Confirmar"),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              onPressed: _createWeeklyTimeslots,
              icon: const Icon(Icons.schedule),
              label: const Text("Disponibilizar agenda semanal"),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
        onRefresh: _fetchAppointments,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Agendamentos Confirmados",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (confirmedAppointments.isEmpty)
              const Text("Nenhum agendamento confirmado."),
            ...confirmedAppointments.map((a) => _buildAppointmentItem(a)),

            const SizedBox(height: 24),
            const Text(
              "Solicitações Pendentes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (pendingAppointments.isEmpty)
              const Text("Nenhuma solicitação pendente."),
            ...pendingAppointments.map((a) => _buildAppointmentItem(a, showConfirm: true)),
          ],
        ),
      ),
    );
  }
}
