// agendamento_service.dart
import 'package:dio/dio.dart';
import 'dio_config.dart';

class AgendamentoService {
  final Dio dio = DioConfig.buildDioClient();

  Future<void> agendar(String nome, String contato, String dia, String horario) async {
    try {
      final response = await dio.post(
        '/agendamentos',
        data: {
          'nome': nome,
          'contato': contato,
          'dia': dia,
          'horario': horario,
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
