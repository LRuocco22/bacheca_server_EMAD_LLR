import 'dart:io';
import 'dart:math';

/// Salva i curriculum (PDF) su disco, nella cartella data/uploads/.
/// Nel file JSON delle candidature si memorizza solo il nome del file.
class CvStorage {
  final String dir;
  final Random _rng = Random.secure();

  CvStorage(this.dir);

  Future<void> init() async {
    await Directory(dir).create(recursive: true);
  }

  /// Salva i byte con un nome univoco generato dal server
  /// (mai il nome scelto dal candidato) e restituisce il nome del file.
  Future<String> save(List<int> bytes) async {
    final name =
        '${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000000000)}.pdf';
    await File('$dir/$name').writeAsBytes(bytes, flush: true);
    return name;
  }

  File file(String name) => File('$dir/$name');
}
