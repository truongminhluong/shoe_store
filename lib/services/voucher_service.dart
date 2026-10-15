import '../core/network/api_client.dart';
import '../models/voucher_model.dart';

class VoucherService {
  Future<VoucherValidationModel> validateVoucher(
    VoucherValidationRequest request,
  ) async {
    final response = await ApiClient.post(
      '/vouchers/validate',
      body: request.toJson(),
    );
    return VoucherValidationModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}
