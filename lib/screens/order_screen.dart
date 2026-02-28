import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание заказа'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => OrderController(),
        child: const _OrderBody(),
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrderController>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Успешный результат
          if (controller.isSuccess && controller.order != null) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Заказ #${controller.order!.orderId} создан!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'Статус: ${controller.order!.status}',
              textAlign: TextAlign.center,
            ),
            if (controller.order!.paymentUrl != null)
              Text(
                'Ссылка: ${controller.order!.paymentUrl}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blue),
              ),
            const SizedBox(height: 24),
          ],

          // Индикатор загрузки
          if (controller.isLoading) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            const Text(
              'Создаём заказ...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],

          // Текст ошибки
          if (controller.isError && controller.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Кнопка "Создать заказ" / "Повторить"
          ElevatedButton(
            // Блокируем кнопку во время загрузки
            onPressed: controller.isLoading
                ? null
                : () {
                    context.read<OrderController>().submitOrder(
                          userId: 1,
                          serviceId: 42,
                        );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: controller.isError ? Colors.orange : null,
            ),
            child: Text(
              controller.isError ? 'Повторить попытку' : 'Создать заказ',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
