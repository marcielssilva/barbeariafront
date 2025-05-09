// dio_config.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioConfig {
  static Dio buildDioClient() {
    String baseUrl;

    if (kIsWeb) {
      baseUrl = 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8080/api';
    } else {
      baseUrl = 'http://localhost:8080/api';
    }

    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
  }
}


