import '../core/network/api_client.dart';
import '../models/address_model.dart';

class AddressService {
  Future<List<AddressModel>> getAddresses() async {
    final response = await ApiClient.get('/addresses');
    final data = response['data'];
    if (data is! List) {
      throw Exception('Dữ liệu địa chỉ không hợp lệ');
    }
    return data
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> getAddressById(String addressId) async {
    final response = await ApiClient.get('/addresses/$addressId');
    return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AddressModel> createAddress(AddressInput input) async {
    final response = await ApiClient.post('/addresses', body: input.toJson());
    return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AddressModel> updateAddress(
    String addressId,
    AddressInput changes,
  ) async {
    final response = await ApiClient.patch(
      '/addresses/$addressId',
      body: changes.toJson(),
    );
    return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AddressModel> setDefaultAddress(String addressId) async {
    final response = await ApiClient.put('/addresses/$addressId/default');
    return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteAddress(String addressId) async {
    await ApiClient.delete('/addresses/$addressId');
  }
}
