import 'dart:convert';
import 'dart:math';

/// Token opachi in memoria: token -> userId.
class TokenService {
  final Map<String, int> _tokens = {};
  final Random _rng = Random.secure();

  String issue(int userId) {
    final bytes = List<int>.generate(32, (_) => _rng.nextInt(256));
    final token = base64Url.encode(bytes).replaceAll('=', '');
    _tokens[token] = userId;
    return token;
  }

  int? userIdFor(String token) => _tokens[token];

  void revoke(String token) => _tokens.remove(token);
}