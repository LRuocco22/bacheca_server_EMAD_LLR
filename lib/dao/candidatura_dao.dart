import '../models/candidatura.dart';
import '../utils/validators.dart';
import 'json_store.dart';

class CandidaturaDao {
  final JsonCollection _col;

  CandidaturaDao(this._col);

  Future<void> load() => _col.load();

  Candidatura? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Candidatura.fromJson(m);
    }
    return null;
  }

  /// Candidature ricevute per un annuncio, dalla più recente.
  List<Candidatura> byAnnuncio(int annuncioId) {
    final list = _col
        .all()
        .map(Candidatura.fromJson)
        .where((c) => c.annuncioId == annuncioId)
        .toList();
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  int countByAnnuncio(int annuncioId) =>
      _col.all().where((m) => m['annuncioId'] == annuncioId).length;

  Future<Candidatura> create({
    required int annuncioId,
    required String nome,
    required String cognome,
    required String email,
    required String cvFile,
    required String cvNomeOriginale,
  }) async {
    final candidatura = Candidatura(
      id: _col.nextId(),
      annuncioId: annuncioId,
      nome: nome,
      cognome: cognome,
      email: email,
      cvFile: cvFile,
      cvNomeOriginale: cvNomeOriginale,
      createdAt: formatIsoUtc(DateTime.now()),
    );
    _col.add(candidatura.toJson());
    await _col.save();
    return candidatura;
  }
}
