class CheckoutItemInputModel {
  final String variantId;
  final int quantity;

  const CheckoutItemInputModel({
    required this.variantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'variantId': variantId,
    'quantity': quantity,
  };
}
