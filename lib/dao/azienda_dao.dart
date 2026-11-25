import '../errors/api_exception.dart';
import '../models/azienda.dart';
import '../utils/validators.dart';
import 'json_store.dart';

class AziendaDao {
  final JsonCollection _col;

  AziendaDao(this._col);

  Future<void> load() => _col.load();

  bool get needsSeed => !_col.existedOnDisk;

  Azienda? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Azienda.fromJson(m);
    }
    return null;
  }

  /// Ricerca case-insensitive.
  Azienda? findByEmail(String email) {
    final lower = email.toLowerCase();
    for (final m in _col.all()) {
      if ((m['email'] as String).toLowerCase() == lower) {
        return Azienda.fromJson(m);
      }
    }
    return null;
  }

  bool emailExists(String email) => findByEmail(email) != null;

  /// Controllo duplicati e inserimento avvengono senza await in mezzo (atomici).
  Future<Azienda> create({
    required String nome,
    required String email,
    required String passwordHash,
    required String salt,
    String? createdAt,
  }) async {
    if (emailExists(email)) {
      throw ApiException(409, 'Esiste già un account con questa email');
    }
    final azienda = Azienda(
      id: _col.nextId(),
      nome: nome,
      email: email,
      passwordHash: passwordHash,
      salt: salt,
      createdAt: createdAt ?? formatIsoUtc(DateTime.now()),
    );
    _col.add(azienda.toJson());
    await _col.save();
    return azienda;
  }
}
