class PaymentSessionModel {
  final String paymentUrl;

  const PaymentSessionModel({required this.paymentUrl});

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) {
    final paymentUrl = json['paymentUrl'];
    if (paymentUrl is! String || paymentUrl.isEmpty) {
      throw const FormatException('URL thanh toán không hợp lệ');
    }
    return PaymentSessionModel(paymentUrl: paymentUrl);
  }
}
