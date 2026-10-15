import 'package:shoe_store/models/brand_model.dart';
import 'package:shoe_store/services/brand_service.dart';

class BrandRepository {
  final BrandService _brandService;
  BrandRepository({
    BrandService? brandService,
  }) : _brandService = brandService ?? BrandService();

  Future<List<BrandModel>> getBrands() {
    return _brandService.getBrands();
  }
}