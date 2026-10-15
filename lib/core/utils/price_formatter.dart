class PriceFormatter {
  PriceFormatter._();

  static String format(double price) {
    final value = price.round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(value[i]);
    }

    return '${buffer.toString()}đ';
  }
}
