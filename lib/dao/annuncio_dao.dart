import '../models/annuncio.dart';
import '../utils/validators.dart';
import 'json_store.dart';

class AnnuncioDao {
  final JsonCollection _col;

  AnnuncioDao(this._col);

  Future<void> load() => _col.load();

  bool get needsSeed => !_col.existedOnDisk;

  /// Tutti gli annunci, dal più recente.
  List<Annuncio> all() {
    final list = _col.all().map(Annuncio.fromJson).toList();
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  Annuncio? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Annuncio.fromJson(m);
    }
    return null;
  }

  /// Annunci pubblicati da una certa azienda, dal più recente.
  List<Annuncio> byAzienda(int aziendaId) =>
      all().where((a) => a.aziendaId == aziendaId).toList();

  Future<Annuncio> create({
    required int aziendaId,
    required String aziendaNome,
    required String titolo,
    required String descrizione,
    String? createdAt,
  }) async {
    final annuncio = Annuncio(
      id: _col.nextId(),
      aziendaId: aziendaId,
      aziendaNome: aziendaNome,
      titolo: titolo,
      descrizione: descrizione,
      createdAt: createdAt ?? formatIsoUtc(DateTime.now()),
    );
    _col.add(annuncio.toJson());
    await _col.save();
    return annuncio;
  }
}
