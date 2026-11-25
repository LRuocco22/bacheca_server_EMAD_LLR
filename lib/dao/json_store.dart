import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Collezione generica persistita su file JSON (array di oggetti con "id" intero).
/// Cache in memoria caricata all'avvio, scrittura atomica (tmp + rename),
/// scritture serializzate da una coda di Future.
class JsonCollection {
  final String path;
  final List<Map<String, dynamic>> _items = [];
  int _lastId = 0;
  Future<void> _queue = Future<void>.value();

  /// true se il file esisteva già al momento del load() (usato dal seeder).
  bool existedOnDisk = false;

  JsonCollection(this.path);

  Future<void> load() async {
    final file = File(path);
    existedOnDisk = await file.exists();
    _items.clear();
    if (existedOnDisk) {
      final text = await file.readAsString();
      if (text.trim().isNotEmpty) {
        final data = jsonDecode(text) as List<dynamic>;
        for (final e in data) {
          _items.add(Map<String, dynamic>.from(e as Map));
        }
      }
    }
    _lastId = 0;
    for (final e in _items) {
      final id = e['id'] as int;
      if (id > _lastId) _lastId = id;
    }
  }

  List<Map<String, dynamic>> all() => List.unmodifiable(_items);

  /// Prossimo id autoincrementale (sincrono: nessun await tra nextId e add).
  int nextId() => ++_lastId;

  void add(Map<String, dynamic> item) => _items.add(item);

  bool replace(int id, Map<String, dynamic> item) {
    final index = _items.indexWhere((e) => e['id'] == id);
    if (index < 0) return false;
    _items[index] = item;
    return true;
  }

  /// Salva lo stato corrente. Lo snapshot è preso subito, la scrittura è in coda.
  Future<void> save() {
    final snapshot = const JsonEncoder.withIndent('  ').convert(_items);
    final op = _queue.then((_) => _write(snapshot));
    _queue = op.catchError((_) {});
    return op;
  }

  Future<void> _write(String content) async {
    final tmp = File('$path.tmp');
    await tmp.parent.create(recursive: true);
    await tmp.writeAsString(content, flush: true);
    await tmp.rename(path);
  }
}