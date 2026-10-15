import 'package:shoe_store/core/network/api_client.dart';
import 'package:shoe_store/models/brand_model.dart';

class BrandService {
  Future<List<BrandModel>> getBrands() async {
    final response = await ApiClient.get('/brands');
    final data = response['data'];

    if (data is! List) {
      throw Exception('Dữ liệu không hợp lệ: ${data.runtimeType}');
    }
    return data.map((json) => BrandModel.fromJson(json)).toList();
  }
}
