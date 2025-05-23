// agendamento_service.dart
import 'package:dio/dio.dart';
import '../config/dio_config.dart';

class AgendamentoService {
  final Dio dio = DioConfig.buildDioClient();

  Future<void> agendar(String nome, String contato, String dia, String horario, String serviceType) async {
    try {
      final response = await dio.post(
        '/appointments',
        data: {
          'barberId': "bdf70c95-6c33-4a39-aef3-f98e3f3b77a0", // Replace with actual selection logic if needed
          'customerId': "4242bda5-74c6-4cd3-8432-4bb1d00c3645", // TODO-> quando implementar login, isso nao vai ser mais hardcoded (id do user)
          'date': dia, // or diaController.text
          'time': horario, // or horarioController.text
          'serviceType': "HAIRCUT", // You can make this dynamic later
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
