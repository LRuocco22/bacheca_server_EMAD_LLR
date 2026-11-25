import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../errors/api_exception.dart';

final RegExp _passwordRe = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,64}$');
final RegExp _emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

/// Dimensione massima del curriculum: 5 MB.
const int maxCvBytes = 5 * 1024 * 1024;

/// Data ISO-8601 UTC senza frazioni di secondo: 2026-11-01T10:00:00Z.
String formatIsoUtc(DateTime d) {
  final u = d.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}'
      'T${two(u.hour)}:${two(u.minute)}:${two(u.second)}Z';
}

/// Legge il body come oggetto JSON; JSON non valido o non-oggetto -> FormatException (400).
Future<Map<String, dynamic>> readJsonObject(Request request) async {
  final text = await request.readAsString();
  final decoded = jsonDecode(text);
  if (decoded is! Map) {
    throw const FormatException('Il corpo deve essere un oggetto JSON');
  }
  return Map<String, dynamic>.from(decoded);
}

/// Stringa obbligatoria (dopo trim) con lunghezza tra min e max.
String _text(Map<String, dynamic> m, String key, String label, int max,
    {int min = 1}) {
  final v = m[key];
  if (v is! String || v.trim().isEmpty) {
    throw ApiException(422, '$label obbligatorio');
  }
  final s = v.trim();
  if (s.length < min) {
    throw ApiException(422, '$label troppo corto (minimo $min caratteri)');
  }
  if (s.length > max) {
    throw ApiException(422, '$label troppo lungo (massimo $max caratteri)');
  }
  return s;
}

/// Email obbligatoria e valida, normalizzata in minuscolo.
String _email(Map<String, dynamic> m) {
  final v = m['email'];
  if (v is! String || !_emailRe.hasMatch(v.trim())) {
    throw ApiException(422, 'Email non valida');
  }
  return v.trim().toLowerCase();
}

// ---------------------------------------------------------------- Auth

({String nome, String email, String password}) validateRegister(
    Map<String, dynamic> b) {
  final nome = _text(b, 'nome', 'Nome azienda', 80, min: 2);
  final email = _email(b);
  final password = b['password'];
  if (password is! String || !_passwordRe.hasMatch(password)) {
    throw ApiException(
        422, 'Password non valida: 8-64 caratteri con almeno una lettera e un numero');
  }
  return (nome: nome, email: email, password: password);
}

// ---------------------------------------------------------------- Annunci

({String titolo, String descrizione}) validateAnnuncio(Map<String, dynamic> b) {
  final titolo = _text(b, 'titolo', 'Titolo', 100, min: 3);
  final descrizione = _text(b, 'descrizione', 'Descrizione', 2000, min: 10);
  return (titolo: titolo, descrizione: descrizione);
}

// ---------------------------------------------------------------- Candidature

({String nome, String cognome, String email}) validateCandidatura(
    Map<String, dynamic> campi) {
  final nome = _text(campi, 'nome', 'Nome', 50);
  final cognome = _text(campi, 'cognome', 'Cognome', 50);
  final email = _email(campi);
  return (nome: nome, cognome: cognome, email: email);
}

/// Il curriculum è obbligatorio, al massimo 5 MB e deve essere un PDF.
/// Si controllano i primi byte del file ("%PDF"), non solo l'estensione.
List<int> validateCv(List<int>? bytes) {
  if (bytes == null || bytes.isEmpty) {
    throw ApiException(422, 'Allega il curriculum');
  }
  if (bytes.length > maxCvBytes) {
    throw ApiException(422, 'Il curriculum supera la dimensione massima di 5 MB');
  }
  final isPdf = bytes.length >= 4 &&
      bytes[0] == 0x25 && // %
      bytes[1] == 0x50 && // P
      bytes[2] == 0x44 && // D
      bytes[3] == 0x46; // F
  if (!isPdf) {
    throw ApiException(422, 'Il curriculum deve essere un file PDF');
  }
  return bytes;
}
