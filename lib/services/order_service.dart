import '../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  Future<OrderModel> createOrder({
    required CreateOrderRequest request,
    required String idempotencyKey,
  }) async {
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }

    final response = await ApiClient.post(
      '/orders',
      body: request.toJson(),
      idempotencyKey: idempotencyKey,
    );
    return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await ApiClient.get('/orders');
    final data = response['data'];
    if (data is! List) {
      throw Exception('Dữ liệu đơn hàng không hợp lệ');
    }
    return data
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await ApiClient.get('/orders/$orderId');
    return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> cancelOrder(String orderId) async {
    final response = await ApiClient.put('/orders/$orderId/cancel');
    return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
