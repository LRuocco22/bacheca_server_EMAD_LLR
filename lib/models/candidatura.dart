/// Risposta di un candidato (non registrato) a un annuncio.
class Candidatura {
  final int id;
  final int annuncioId;
  final String nome;
  final String cognome;
  final String email;
  final String cvFile; // nome del file salvato in data/uploads/
  final String cvNomeOriginale; // nome del file scelto dal candidato
  final String createdAt; // ISO-8601 UTC

  const Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.cvFile,
    required this.cvNomeOriginale,
    required this.createdAt,
  });

  factory Candidatura.fromJson(Map<String, dynamic> j) => Candidatura(
        id: j['id'] as int,
        annuncioId: j['annuncioId'] as int,
        nome: j['nome'] as String,
        cognome: j['cognome'] as String,
        email: j['email'] as String,
        cvFile: j['cvFile'] as String,
        cvNomeOriginale: j['cvNomeOriginale'] as String,
        createdAt: j['createdAt'] as String,
      );

  /// Serializzazione completa (solo per la persistenza su file).
  Map<String, dynamic> toJson() => {
        'id': id,
        'annuncioId': annuncioId,
        'nome': nome,
        'cognome': cognome,
        'email': email,
        'cvFile': cvFile,
        'cvNomeOriginale': cvNomeOriginale,
        'createdAt': createdAt,
      };

  /// Serializzazione pubblica: il percorso interno del file non esce dal server
  /// (il CV si scarica da /api/candidature/<id>/cv).
  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'annuncioId': annuncioId,
        'nome': nome,
        'cognome': cognome,
        'email': email,
        'cvNomeOriginale': cvNomeOriginale,
        'createdAt': createdAt,
      };
}
