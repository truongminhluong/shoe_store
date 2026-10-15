import '../core/network/api_client.dart';
import '../models/payment_session_model.dart';

class PaymentService {
  // Current backend route is mounted at /api/payment and exposes /vnpay/create.
  Future<PaymentSessionModel> createVnpayPayment(String orderId) async {
    final response = await ApiClient.post(
      '/payment/vnpay/create',
      body: {'orderId': orderId},
    );
    return PaymentSessionModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}
