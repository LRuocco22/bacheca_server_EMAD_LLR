/// Offerta di lavoro pubblicata da un'azienda.
class Annuncio {
  final int id;
  final int aziendaId;
  final String aziendaNome; // copia del nome, per mostrarlo in bacheca
  final String titolo;
  final String descrizione;
  final String createdAt; // ISO-8601 UTC

  const Annuncio({
    required this.id,
    required this.aziendaId,
    required this.aziendaNome,
    required this.titolo,
    required this.descrizione,
    required this.createdAt,
  });

  factory Annuncio.fromJson(Map<String, dynamic> j) => Annuncio(
        id: j['id'] as int,
        aziendaId: j['aziendaId'] as int,
        aziendaNome: j['aziendaNome'] as String,
        titolo: j['titolo'] as String,
        descrizione: j['descrizione'] as String,
        createdAt: j['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'aziendaId': aziendaId,
        'aziendaNome': aziendaNome,
        'titolo': titolo,
        'descrizione': descrizione,
        'createdAt': createdAt,
      };
}
