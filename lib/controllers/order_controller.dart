import 'package:flutter/foundation.dart';

import '../exceptions/api_exception.dart';
import '../models/order.dart';
import '../services/order_service.dart';

// Перечисление состояний контроллера
enum OrderStatus { initial, loading, success, error }

class OrderController extends ChangeNotifier {
  final OrderService _service;

  OrderController({OrderService? service})
      : _service = service ?? OrderService();

  // --- State ---
  OrderStatus _status = OrderStatus.initial;
  Order? _order;
  String? _errorMessage;

  // --- Getters ---
  OrderStatus get status => _status;
  Order? get order => _order;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == OrderStatus.loading;
  bool get isSuccess => _status == OrderStatus.success;
  bool get isError => _status == OrderStatus.error;

  // --- Methods ---
  Future<void> submitOrder({
    required int userId,
    required int serviceId,
  }) async {
    // Устанавливаем состояние загрузки
    _status = OrderStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.createOrder(
        userId: userId,
        serviceId: serviceId,
      );

      // Успех
      _order = result;
      _status = OrderStatus.success;
    } on ApiException catch (e) {
      // Ошибка — сохраняем текст
      _errorMessage = e.message;
      _status = OrderStatus.error;
    } catch (e) {
      _errorMessage = 'Неизвестная ошибка';
      _status = OrderStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = OrderStatus.initial;
    _order = null;
    _errorMessage = null;
    notifyListeners();
  }
}
