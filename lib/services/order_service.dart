import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../exceptions/api_exception.dart';
import '../models/order.dart';

class OrderService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com'; 
  static const Duration _timeout = Duration(seconds: 10);

  Future<Order> createOrder({
    required int userId,
    required int serviceId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/orders'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'serviceId': serviceId,
            }),
          )
          .timeout(_timeout);

      // Успешный ответ
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Order.fromJson(json);
      }

      // Ошибка от сервера (400+)
      if (response.statusCode >= 400) {
        String errorMessage;
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = json['message'] as String? ?? 'Ошибка сервера';
        } catch (_) {
          errorMessage = 'Ошибка сервера (${response.statusCode})';
        }
        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }

      // Прочие статусы
      throw ApiException(
        message: 'Неожиданный статус ответа: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        message: 'Превышено время ожидания (10 сек). Попробуйте снова.',
      );
    } on SocketException {
      throw const ApiException(
        message: 'Нет подключения к интернету. Проверьте сеть.',
      );
    } on FormatException {
      throw const ApiException(
        message: 'Ошибка обработки ответа сервера.',
      );
    } catch (e) {
      throw ApiException(
        message: 'Неизвестная ошибка: $e',
      );
    }
  }
}
