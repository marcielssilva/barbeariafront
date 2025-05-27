// // agendamento_service.dart
// import 'package:barbeariafront/api/api_client.dart';
// import 'package:dio/dio.dart';
// import '../config/dio_config.dart';
//
// class AgendamentoService {
//   final Dio dio = ApiClient.dio;
//
//   Future<void> agendar(String nome, String contato, String dia, String horario, String serviceType) async {
//     try {
//       final response = await dio.post(
//         '/appointments',
//         data: {
//           'barberId': 'd8493d62-30e2-400d-827a-7e271011074e',
//           'customerId': 1,
//           'date': dia, // or diaController.text
//           'time': horario, // or horarioController.text
//           'serviceType': serviceType, // You can make this dynamic later
//         },
//       );
//
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         throw Exception('Erro ao agendar: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       if (e.response != null) {
//         throw Exception('Erro da API: ${e.response?.data}');
//       } else {
//         throw Exception('Erro de rede: ${e.message}');
//       }
//     }
//   }
// }
