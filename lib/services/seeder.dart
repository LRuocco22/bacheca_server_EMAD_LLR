import '../dao/annuncio_dao.dart';
import '../dao/azienda_dao.dart';
import 'password_service.dart';

/// Crea i dati di prova se i rispettivi file JSON non esistono.
/// Account di prova: demo@bacheca.it / Demo1234
class Seeder {
  static Future<void> run({
    required AziendaDao aziende,
    required AnnuncioDao annunci,
  }) async {
    if (!aziende.needsSeed) return;

    final salt = PasswordService.generateSalt();
    final demo = await aziende.create(
      nome: 'Demo Lavoro Srl',
      email: 'demo@bacheca.it',
      passwordHash: PasswordService.hash('Demo1234', salt),
      salt: salt,
      createdAt: '2026-11-01T09:00:00Z',
    );

    if (!annunci.needsSeed) return;
    await annunci.create(
      aziendaId: demo.id,
      aziendaNome: demo.nome,
      titolo: 'Addetto/a customer care',
      descrizione:
          'Cerchiamo una persona per il servizio clienti telefonico e via email. '
          'Contratto part-time, sede a Napoli.',
      createdAt: '2026-11-02T10:00:00Z',
    );
    await annunci.create(
      aziendaId: demo.id,
      aziendaNome: demo.nome,
      titolo: 'Magazziniere',
      descrizione:
          'Gestione del magazzino, carico e scarico merci. '
          'Preferibile patentino per il muletto. Tempo pieno, sede a Salerno.',
      createdAt: '2026-11-03T11:30:00Z',
    );
  }
}
