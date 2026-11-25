import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/error_middleware.dart';
import '../utils/validators.dart';

/// R5 Bacheca pubblica (elenco e dettaglio), R4 Pubblicazione annuncio,
/// R7 Elenco dei propri annunci (area riservata).
class AnnuncioController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature;

  AnnuncioController(this.annunci, this.candidature);

  Router get router {
    final r = Router();
    // Pubbliche (candidato, senza login)
    r.get('/api/annunci', _list);
    r.get('/api/annunci/<id|[0-9]+>', _get);
    // Riservate (azienda autenticata)
    r.post('/api/annunci', guard(_create));
    r.get('/api/azienda/annunci', guard(_mine));
    return r;
  }

  Response _list(Request req) =>
      jsonResponse(annunci.all().map((a) => a.toJson()).toList());

  Response _get(Request req, String id) {
    final annuncio = annunci.findById(int.parse(id));
    if (annuncio == null) throw ApiException(404, 'Annuncio non trovato');
    return jsonResponse(annuncio.toJson());
  }

  Future<Response> _create(Request req) async {
    final azienda = currentAzienda(req)!;
    final input = validateAnnuncio(await readJsonObject(req));
    final annuncio = await annunci.create(
      aziendaId: azienda.id,
      aziendaNome: azienda.nome,
      titolo: input.titolo,
      descrizione: input.descrizione,
    );
    return jsonResponse(annuncio.toJson(), status: 201);
  }

  /// Annunci dell'azienda loggata, con il numero di candidature ricevute.
  Response _mine(Request req) {
    final azienda = currentAzienda(req)!;
    final result = annunci
        .byAzienda(azienda.id)
        .map((a) => {
              ...a.toJson(),
              'numCandidature': candidature.countByAnnuncio(a.id),
            })
        .toList();
    return jsonResponse(result);
  }
}
