// dio_config.dart
import 'package:dio/dio.dart';

class DioConfig {
  static Dio buildDioClient() {

    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://172.18.0.1:8080',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Adicione interceptadores, logs, auth, etc., se necessário
    return dio;
  }


}
