# Bacheca annunci di lavoro — back-end

Server REST in Dart (`shelf` + `shelf_router`) per l'app Flutter della bacheca.
I dati sono salvati in file JSON nella cartella `data/`, i curriculum (PDF) in `data/uploads/`.

## Avvio

```
dart pub get
dart run bin/server.dart
```

Il server ascolta sulla porta 8080. Al primo avvio crea dei dati di prova:
- azienda **Demo Lavoro Srl** — email `demo@bacheca.it`, password `Demo1234`
- due annunci pubblicati da questa azienda

Per ripartire da zero basta fermare il server e cancellare la cartella `data/`.

## Struttura

```
bin/server.dart            avvio: DAO, controller, middleware
lib/models/                Azienda, Annuncio, Candidatura
lib/dao/                   lettura/scrittura dei file JSON (JsonCollection)
lib/controllers/           rotte REST
lib/middleware/            autenticazione (token Bearer) e gestione errori
lib/services/              password (salt + SHA-256), token, salvataggio CV, seeder
lib/utils/validators.dart  validazione dei dati in ingresso
test.http                  richieste di prova (estensione REST Client di VS Code)
```

## API

Gli errori hanno sempre la forma `{"error": "messaggio"}`.
Le rotte con 🔒 richiedono l'header `Authorization: Bearer <token>`.

| Metodo | Percorso | Descrizione | Req. |
|---|---|---|---|
| POST | `/api/auth/register` | registra un'azienda `{nome, email, password}` | R1 |
| POST | `/api/auth/login` | login `{email, password}` → `{token, azienda}` | R2 |
| POST | `/api/auth/logout` 🔒 | logout (il token non vale più) | R3 |
| GET | `/api/auth/me` 🔒 | azienda autenticata | — |
| POST | `/api/annunci` 🔒 | pubblica un annuncio `{titolo, descrizione}` | R4 |
| GET | `/api/annunci` | bacheca pubblica | R5 |
| GET | `/api/annunci/<id>` | dettaglio annuncio | R5 |
| POST | `/api/annunci/<id>/candidature` | candidatura, multipart: `nome`, `cognome`, `email`, `cv` (PDF) | R6 |
| GET | `/api/azienda/annunci` 🔒 | annunci dell'azienda con `numCandidature` | R7 |
| GET | `/api/azienda/annunci/<id>/candidature` 🔒 | candidature ricevute | R7 |
| GET | `/api/candidature/<id>/cv` 🔒 | scarica il curriculum (PDF) | R7 |

Codici usati: 200/201/204 ok, 400 richiesta malformata, 401 non autenticato,
403 risorsa di un'altra azienda, 404 non trovato, 409 email già registrata,
422 dati non validi.

## Collegare il telefono

Telefono e computer devono essere sulla stessa rete Wi-Fi. Nell'app si usa
`http://<IP del computer>:8080`. Su Chromebook va attivato il port forwarding
della porta 8080 (Impostazioni → Linux → Port forwarding) e si usa l'IP Wi-Fi
del Chromebook.
