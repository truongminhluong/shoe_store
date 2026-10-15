import '../models/voucher_model.dart';
import '../services/voucher_service.dart';

class VoucherRepository {
  final VoucherService _voucherService;

  VoucherRepository({VoucherService? voucherService})
    : _voucherService = voucherService ?? VoucherService();

  Future<VoucherValidationModel> validateVoucher(
    VoucherValidationRequest request,
  ) => _voucherService.validateVoucher(request);
}
