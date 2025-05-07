// services/client_service.dart
import 'package:dio/dio.dart';
import '../models/client_model.dart';
import '../config/dio_config.dart';

class ClientService {
  final Dio _dio = DioConfig.buildDioClient();

  Future<Client> createClient(Client client) async {
    try {
      final response = await _dio.post(
        '/api/clients',
        data: client.toJson(),
      );

      if (response.statusCode == 201) {
        return Client.fromJson(response.data);
      } else {
        throw Exception('Failed to create client');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Client>> getClients() async {
    try {
      final response = await _dio.get('/api/clients');
      return (response.data as List)
          .map((json) => Client.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // TODO!!!
  // Add more methods for update/delete as needed

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] ?? 'Unknown error' : 'Server error';
      return Exception('$message (${e.response?.statusCode})');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}