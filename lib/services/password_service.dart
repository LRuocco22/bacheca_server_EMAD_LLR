import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordService {
  static final Random _rng = Random.secure();

  /// Salt casuale di 16 byte in base64url.
  static String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// SHA-256 di salt + password.
  static String hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  /// Confronto a tempo costante.
  static bool verify(String password, String salt, String expectedHash) {
    final actual = hash(password, salt);
    if (actual.length != expectedHash.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return diff == 0;
  }
}