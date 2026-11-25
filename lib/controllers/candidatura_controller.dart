import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/error_middleware.dart';
import '../services/cv_storage.dart';
import '../utils/validators.dart';

/// R6 Candidatura con CV (candidato, senza login),
/// R7 Candidature ricevute e apertura del CV (azienda autenticata).
class CandidaturaController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature;
  final CvStorage storage;

  CandidaturaController(this.annunci, this.candidature, this.storage);

  Router get router {
    final r = Router();
    // Pubblica: il candidato non fa login
    r.post('/api/annunci/<id|[0-9]+>/candidature', _create);
    // Riservate: solo l'azienda proprietaria dell'annuncio
    r.get(
      '/api/azienda/annunci/<id|[0-9]+>/candidature',
      (Request req, String id) =>
          guard((inner) => _byAnnuncio(inner, int.parse(id)))(req),
    );
    r.get(
      '/api/candidature/<id|[0-9]+>/cv',
      (Request req, String id) =>
          guard((inner) => _cv(inner, int.parse(id)))(req),
    );
    return r;
  }

  /// Il form arriva come multipart/form-data:
  /// campi di testo "nome", "cognome", "email" + file "cv" (PDF).
  Future<Response> _create(Request req, String id) async {
    final annuncio = annunci.findById(int.parse(id));
    if (annuncio == null) throw ApiException(404, 'Annuncio non trovato');

    final form = req.formData();
    if (form == null) {
      throw ApiException(
          400, 'La candidatura deve essere inviata come multipart/form-data');
    }

    final campi = <String, String>{};
    List<int>? cvBytes;
    String? cvNome;
    await for (final campo in form.formData) {
      if (campo.name == 'cv') {
        cvBytes = await campo.part.readBytes();
        cvNome = campo.filename;
      } else {
        campi[campo.name] = await campo.part.readString();
      }
    }

    final input = validateCandidatura(campi);
    final bytes = validateCv(cvBytes);
    final nomeOriginale =
        (cvNome == null || cvNome.trim().isEmpty) ? 'curriculum.pdf' : cvNome.trim();

    final fileSalvato = await storage.save(bytes);
    final candidatura = await candidature.create(
      annuncioId: annuncio.id,
      nome: input.nome,
      cognome: input.cognome,
      email: input.email,
      cvFile: fileSalvato,
      cvNomeOriginale: nomeOriginale,
    );
    return jsonResponse(candidatura.toPublicJson(), status: 201);
  }

  Response _byAnnuncio(Request req, int annuncioId) {
    final azienda = currentAzienda(req)!;
    final annuncio = annunci.findById(annuncioId);
    if (annuncio == null) throw ApiException(404, 'Annuncio non trovato');
    if (annuncio.aziendaId != azienda.id) {
      throw ApiException(403, 'Questo annuncio non è tuo');
    }
    return jsonResponse(candidature
        .byAnnuncio(annuncioId)
        .map((c) => c.toPublicJson())
        .toList());
  }

  /// Restituisce il PDF; solo l'azienda che ha pubblicato l'annuncio può vederlo.
  Response _cv(Request req, int candidaturaId) {
    final azienda = currentAzienda(req)!;
    final candidatura = candidature.findById(candidaturaId);
    if (candidatura == null) {
      throw ApiException(404, 'Candidatura non trovata');
    }
    final annuncio = annunci.findById(candidatura.annuncioId);
    if (annuncio == null || annuncio.aziendaId != azienda.id) {
      throw ApiException(403, 'Non puoi vedere questo curriculum');
    }
    final file = storage.file(candidatura.cvFile);
    if (!file.existsSync()) {
      throw ApiException(404, 'File del curriculum non trovato');
    }
    // Nome "pulito" per l'header (solo caratteri sicuri)
    final nomeSicuro =
        candidatura.cvNomeOriginale.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return Response.ok(
      file.openRead(),
      headers: {
        'content-type': 'application/pdf',
        'content-disposition': 'inline; filename="$nomeSicuro"',
      },
    );
  }
}
