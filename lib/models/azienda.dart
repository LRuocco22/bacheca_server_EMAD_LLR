/// Azienda registrata: pubblica annunci e consulta le candidature ricevute.
class Azienda {
  final int id;
  final String nome;
  final String email;
  final String passwordHash;
  final String salt;
  final String createdAt; // ISO-8601 UTC

  const Azienda({
    required this.id,
    required this.nome,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  factory Azienda.fromJson(Map<String, dynamic> j) => Azienda(
        id: j['id'] as int,
        nome: j['nome'] as String,
        email: j['email'] as String,
        passwordHash: j['passwordHash'] as String,
        salt: j['salt'] as String,
        createdAt: j['createdAt'] as String,
      );

  /// Serializzazione completa (solo per la persistenza su file).
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'passwordHash': passwordHash,
        'salt': salt,
        'createdAt': createdAt,
      };

  /// Serializzazione pubblica: senza passwordHash/salt.
  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'createdAt': createdAt,
      };
}
