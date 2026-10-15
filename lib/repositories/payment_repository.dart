import '../models/payment_session_model.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository({PaymentService? paymentService})
    : _paymentService = paymentService ?? PaymentService();

  Future<PaymentSessionModel> createVnpayPayment(String orderId) =>
      _paymentService.createVnpayPayment(orderId);
}
