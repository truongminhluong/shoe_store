import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressRepository {
  final AddressService _addressService;

  AddressRepository({AddressService? addressService})
    : _addressService = addressService ?? AddressService();

  Future<List<AddressModel>> getAddresses() => _addressService.getAddresses();

  Future<AddressModel> getAddressById(String addressId) =>
      _addressService.getAddressById(addressId);

  Future<AddressModel> createAddress(AddressInput input) =>
      _addressService.createAddress(input);

  Future<AddressModel> updateAddress(String addressId, AddressInput changes) =>
      _addressService.updateAddress(addressId, changes);

  Future<AddressModel> setDefaultAddress(String addressId) =>
      _addressService.setDefaultAddress(addressId);

  Future<void> deleteAddress(String addressId) =>
      _addressService.deleteAddress(addressId);
}
