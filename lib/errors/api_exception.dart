/// Eccezione applicativa: viene convertita in {"error": message} con lo status indicato.
class ApiException implements Exception {
  final int status;
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => 'ApiException($status): $message';
}