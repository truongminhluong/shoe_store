import 'dart:convert';
import 'dart:math';

class IdempotencyKey {
  IdempotencyKey._();

  /// Generate once per order submission and retain the result for retries.
  static String generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
