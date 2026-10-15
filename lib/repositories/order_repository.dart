import '../core/utils/idempotency_key.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService _orderService;

  OrderRepository({OrderService? orderService})
    : _orderService = orderService ?? OrderService();

  String createIdempotencyKey() => IdempotencyKey.generate();

  Future<OrderModel> createOrder({
    required CreateOrderRequest request,
    required String idempotencyKey,
  }) => _orderService.createOrder(
    request: request,
    idempotencyKey: idempotencyKey,
  );

  Future<List<OrderModel>> getOrders() => _orderService.getOrders();

  Future<OrderModel> getOrderById(String orderId) =>
      _orderService.getOrderById(orderId);

  Future<OrderModel> cancelOrder(String orderId) =>
      _orderService.cancelOrder(orderId);
}
