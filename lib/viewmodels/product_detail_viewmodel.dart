import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import '../repositories/product_repository.dart';

class ProductDetailViewModel extends Notifier<ProductDetailState> {
  final ProductRepository _productRepository = ProductRepository();

  @override
  ProductDetailState build() {
    return const ProductDetailState();
  }

  Future<void> loadProduct(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _productRepository.getProductById(productId),
        _productRepository.getProductVariants(productId),
        _productRepository.getProducts(),
      ]);

      final product = results[0] as ProductModel;
      final variants = results[1] as List<ProductVariantModel>;
      final allProducts = results[2] as List<ProductModel>;

      final productWithVariants = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        discountPrice: product.discountPrice,
        image: product.image,
        brand: product.brand,
        category: product.category,
        sold: product.sold,
        rating: product.rating,
        isFeatured: product.isFeatured,
        status: product.status,
        variants: variants,
      );

      final relatedProducts = allProducts
          .where((item) => item.id != product.id)
          .where(
            (item) =>
                item.category?.id == product.category?.id ||
                item.brand?.id == product.brand?.id,
          )
          .take(4)
          .toList();

      state = ProductDetailState(
        isLoading: false,
        product: productWithVariants,
        relatedProducts: relatedProducts,
      );
    } catch (e) {
      state = ProductDetailState(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  void selectColor(String colorName) {
    final variants = state.product?.variants ?? [];

    final availableVariants = variants
        .where((variant) => variant.colorName == colorName && variant.stock > 0)
        .toList();

    if (availableVariants.isEmpty) {
      return;
    }

    state = state.copyWith(
      selectedColor: colorName,
      selectedSize: null,
      selectedVariant: null,
      quantity: 1,
    );
  }

  void selectSize(int size) {
    final variants = state.product?.variants ?? [];

    final color = state.selectedColor;

    if (color == null) {
      return;
    }

    ProductVariantModel? variant;

    for (final item in variants) {
      if (item.colorName == color && item.size == size && item.stock > 0) {
        variant = item;
        break;
      }
    }

    if (variant == null) {
      return;
    }

    state = state.copyWith(
      selectedSize: size,
      selectedVariant: variant,
      quantity: 1,
    );
  }

  void increaseQuantity() {
    final variant = state.selectedVariant;

    if (variant == null) {
      return;
    }

    if (state.quantity >= variant.stock) {
      return;
    }

    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decreaseQuantity() {
    if (state.quantity <= 1) {
      return;
    }

    state = state.copyWith(quantity: state.quantity - 1);
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}

class ProductDetailState {
  final bool isLoading;
  final ProductModel? product;
  final String? selectedColor;
  final int? selectedSize;
  final ProductVariantModel? selectedVariant;
  final int quantity;
  final String? errorMessage;
  final List<ProductModel> relatedProducts;

  const ProductDetailState({
    this.isLoading = false,
    this.product,
    this.selectedColor,
    this.selectedSize,
    this.selectedVariant,
    this.quantity = 1,
    this.errorMessage,
    this.relatedProducts = const [],
  });

  ProductDetailState copyWith({
    bool? isLoading,
    ProductModel? product,
    String? selectedColor,
    int? selectedSize,
    ProductVariantModel? selectedVariant,
    int? quantity,
    String? errorMessage,
    List<ProductModel>? relatedProducts,
  }) {
    return ProductDetailState(
      isLoading: isLoading ?? this.isLoading,
      product: product ?? this.product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
      errorMessage: errorMessage,
      relatedProducts: relatedProducts ?? this.relatedProducts,
    );
  }
}
