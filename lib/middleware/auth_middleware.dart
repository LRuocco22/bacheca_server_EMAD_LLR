import 'package:shelf/shelf.dart';

import '../dao/azienda_dao.dart';
import '../models/azienda.dart';
import '../services/token_service.dart';
import 'error_middleware.dart';

const String _aziendaKey = 'bacheca.azienda';
const String _tokenKey = 'bacheca.token';

/// Azienda autenticata della richiesta (null se ospite, cioè un candidato).
Azienda? currentAzienda(Request request) =>
    request.context[_aziendaKey] as Azienda?;

/// Token Bearer valido della richiesta (null se assente/non valido).
String? currentToken(Request request) => request.context[_tokenKey] as String?;

/// Legge "Authorization: Bearer <token>" e, se valido, mette azienda e token nel context.
Middleware authMiddleware(TokenService tokens, AziendaDao aziende) {
  return (Handler inner) {
    return (Request request) {
      var req = request;
      final header = request.headers['authorization'];
      if (header != null && header.toLowerCase().startsWith('bearer ')) {
        final token = header.substring(7).trim();
        final aziendaId = tokens.userIdFor(token);
        if (aziendaId != null) {
          final azienda = aziende.findById(aziendaId);
          if (azienda != null) {
            req = request
                .change(context: {_aziendaKey: azienda, _tokenKey: token});
          }
        }
      }
      return inner(req);
    };
  };
}

/// Protegge un handler: 401 se la richiesta non ha un token valido
/// (area riservata accessibile solo all'azienda autenticata).
Handler guard(Handler handler) {
  return (Request request) {
    if (currentAzienda(request) == null) {
      return jsonError(401, 'Autenticazione richiesta');
    }
    return handler(request);
  };
}
