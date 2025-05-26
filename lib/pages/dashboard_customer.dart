import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardCustomerScreen extends StatefulWidget {
  const DashboardCustomerScreen({super.key});

  @override
  State<DashboardCustomerScreen> createState() =>
      _DashboardCustomerScreenState();
}

// Função para extrair userId do token (cliente)
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
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _setAuthHeader();

      final userId = await _getUserIdFromToken();
      if (userId == null) {
        setState(() => _error = "Usuário não autenticado.");
        return;
      }

      // Aqui você chama a API filtrando por customerId
      final response = await dio.get(
        'http://localhost:8080/api/appointments',
        queryParameters: {'customerId': userId},
      );

      setState(() {
        appointments = response.data;
      });
    } catch (e) {
      setState(() => _error = "Erro ao buscar agendamentos: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    final barberName =
        appointment['barberName']?.toString() ?? 'Barbeiro não disponível';
    final formattedDate = formatDateAndTime(
      appointment['day'],
      appointment['startTime'],
    );
    final serviceType = formatServiceType(
      appointment['serviceType']?.toString(),
    );
    final status = appointment['status']?.toString() ?? 'Status desconhecido';

    return Card(
      child: ListTile(
        title: Text("Barbeiro: $barberName"),
        subtitle: Text(
          "$formattedDate\nServiço: $serviceType\nStatus: $status",
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Agendamentos"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                onRefresh: _fetchAppointments,
                child:
                    appointments.isEmpty
                        ? const Center(
                          child: Text("Nenhum agendamento encontrado."),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentItem(appointments[index]);
                          },
                        ),
              ),
    );
  }
}
