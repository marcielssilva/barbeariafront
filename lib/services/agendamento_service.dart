// agendamento_service.dart
import 'package:dio/dio.dart';
import '../config/dio_config.dart';

class AgendamentoService {
  final Dio dio = DioConfig.buildDioClient();

  Future<void> agendar(String nome, String contato, String dia, String horario) async {
    try {
      final response = await dio.post(
        '/appointments',
        data: {
          'barberId': 1, // Replace with actual selection logic if needed
          'customerId': 1, // TODO-> quando implementar login, isso nao vai ser mais hardcoded (id do user)
          'date': dia, // or diaController.text
          'time': horario, // or horarioController.text
          'serviceType': 'Corte', // You can make this dynamic later
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao agendar: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro da API: ${e.response?.data}');
      } else {
        throw Exception('Erro de rede: ${e.message}');
      }
    }
  }
}
