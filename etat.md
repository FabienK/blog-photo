# État du projet — Blog Photo

Fichier de suivi d'avancement, mis à jour à chaque étape significative. Voir [CLAUDE.md](./CLAUDE.md) pour les règles du projet et [themes.md](./themes.md) pour les thèmes restants.

## 1. Phase actuelle

**Phase 3 — Automatisation** (mécanisme complet et fonctionnel, en attente du mot de passe d'application Gmail)

Phases 0 à 2 terminées le 2026-08-27. **Note de méthode (2026-08-27)** : l'auteur a précisé que le contenu (photos/prompts/textes) et la mise en page ne nécessitent pas de validation intermédiaire — seule la mise en ligne finale requiert son accord explicite (conforme à CLAUDE.md). À partir de maintenant, ces étapes sont exécutées puis rapportées, sans être présentées comme des questions.

Le cycle complet (génération → email preview → réponse affirmative → mise en ligne automatique) est construit : `scripts/run_publication.sh`, `scripts/check_validation.py`, `scripts/publish.sh`, `.github/workflows/deploy.yml`. Les deux jobs launchd sont **chargés et fonctionnels** (`LastExitStatus = 0`, autorisation macOS accordée). Twilio abandonné le 2026-08-27 (procédure d'inscription bloquante) au profit d'une notification par **email** (Gmail SMTP/IMAP) — voir CLAUDE.md, section Déclenchement automatique. Seul point restant : le mot de passe d'application Gmail à renseigner dans `.env`. **Aucune mise en ligne publique n'a eu lieu** — le site tourne uniquement en local. Détail complet dans [automation/AUTOMATISATION.md](./automation/AUTOMATISATION.md).

## 2. Décisions prises

| Date | Décision |
|---|---|
| 2026-08-27 | Le thème "Liberté" est inséré en tête de `themes.md` pour être la première publication, conformément à CLAUDE.md (la liste ne le contenait pas initialement). |
| 2026-08-27 | On commence par un pipeline **manuel** de bout en bout (une publication complète, déclenchée à la main, validation dans le chat) avant de construire l'automatisation launchd/Twilio. |
| 2026-08-27 | Stack technique du site : **Astro** (générateur de site statique), design éditorial maison (police Fraunces + Work Sans, palette sombre/claire selon préférence système). Projet dans `site/`. |
| 2026-08-27 | Hébergement pressenti : **GitHub Pages** (gratuit, illimité pour un dépôt public) — nécessitera un dépôt GitHub côté auteur ; aucune mise en ligne ni push distant tant que l'auteur n'a pas donné son accord explicite (garde-fou CLAUDE.md). |
| 2026-08-27 | Versioning local mis en place : dépôt git initialisé à la racine du projet, premier commit après validation du contenu de "Liberté". |
| 2026-08-27 | Dépôt distant fourni par l'auteur : [github.com/FabienK/blog-photo](https://github.com/FabienK/blog-photo.git), ajouté comme remote `origin`. **Rien poussé pour l'instant** — le push initial constitue une mise en ligne potentielle (si GitHub Pages est activé dessus) et attend donc un accord explicite. |
| 2026-08-27 | Authentification Claude Code en tâche de fond : l'abonnement existant (`claude auth status` → connecté, plan Pro) fonctionne en mode `-p` non-interactif, y compris en environnement dépouillé proche de launchd — testé en session. Pas besoin de clé API séparée. |
| 2026-08-27 | Mode de permission retenu pour les runs automatiques : `--permission-mode acceptEdits` (édition de fichiers + Bash sans invite de confirmation) — testé, suffisant, plus scopé qu'un `--dangerously-skip-permissions`. |
| 2026-08-27 | Mise en ligne automatique sur réponse affirmative (oui/je valide/ok/go/d'accord) : décision explicite de l'auteur. `check_validation.py` sonde les réponses toutes les 10 min et déclenche `publish.sh` (push + déploiement GitHub Pages) sans repasser par le chat. |
| 2026-08-27 | Pas de nom de domaine personnalisé pour GitHub Pages (achat payant, hors gratuité) : URL retenue `https://fabienk.github.io/blog-photo/`. `astro.config.mjs` configuré avec `base: '/blog-photo'`. |
| 2026-08-27 | Si l'auteur ajoute lui-même un nouveau modèle/checkpoint à ShowMe5WH (`presets.json`), l'agent peut l'utiliser normalement — le garde-fou CLAUDE.md interdit à l'agent d'installer des modèles lui-même, pas d'utiliser ceux ajoutés par l'auteur. |
| 2026-08-27 | **Twilio abandonné** : procédure d'inscription/conformité bloquante (formulaires ne progressant pas, écrans blancs, numéro acheté mais incapable d'envoyer). Remplacé par une notification **email** (Gmail SMTP/IMAP), gratuite, avec photo en pièce jointe directe (plus simple que le MMS). CLAUDE.md mis à jour en conséquence avec l'accord explicite de l'auteur. |

## 3. Publication en cours

Thème : **Liberté** (premier thème, retiré de `themes.md`). Dossier : [publications/2026-08-27-liberte/](./publications/2026-08-27-liberte/) — preview brute : [preview.md](./publications/2026-08-27-liberte/preview.md).

Statut par article :

| Article | Idée | Photo générée | Texte rédigé | Mise en page | Preview | Validation contenu (Phase 1) | Validation mise en ligne (Phase 3+) | Tentatives régén. (max 3) |
|---|---|---|---|---|---|---|---|---|
| 1 — L'instant avant l'envol (colombe/cage) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (2026-08-27) | ⏳ en attente | 0 |
| 2 — Le dernier maillon (chaîne brisée, N&B) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (2026-08-27) | ⏳ en attente | 0 |
| 3 — Aucune limite (silhouette, falaise) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (2026-08-27) | ⏳ en attente | 0 |

Site local consultable en dev : `npm --prefix site run dev` puis `http://localhost:4321/liberte` (page d'accueil : `http://localhost:4321/`).

## 4. Historique des publications

Aucune publication réalisée à ce jour.

| Date | Thème | Nb articles | Lien preview/archive | Statut |
|---|---|---|---|---|
| — | — | — | — | — |

## 5. Blocages / questions ouvertes

**Bloquant actuel (nécessite l'auteur, hors périmètre agent) :**

1. Générer un mot de passe d'application Gmail ([myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)) et le renseigner dans `.env` (`GMAIL_APP_PASSWORD`). Seul point restant avant un cycle complet fonctionnel.

**Résolus :**

- ~~Localisation de l'outil ShowMe5WH~~ — résolu le 2026-08-27 : trouvé dans `Documents/Projets Claude code/Image generator /Image-generator/`, actuellement installé et démarré (ComfyUI :8188, backend FastAPI :8000, frontend :5173), presets renseignés. API REST disponible (`POST /api/generate`, `POST /api/batches`) pour un déclenchement programmatique.
- ~~Écart thème "Liberté" vs contenu de `themes.md`~~ — résolu le 2026-08-27 : "Liberté" ajouté en tête de liste.
- ~~Dépôt GitHub pour l'hébergement~~ — résolu le 2026-08-27 : fourni par l'auteur, ajouté comme remote (pas encore poussé).
- ~~Ce que déclenche la réponse~~ — résolu le 2026-08-27 : réponse affirmative = mise en ligne automatique, mécanisme construit (`check_validation.py` / `publish.sh`).
- ~~Feu vert pour charger le job launchd~~ — résolu le 2026-08-27 : chargé et fonctionnel.
- ~~Nom de domaine GitHub Pages~~ — résolu le 2026-08-27 : pas de domaine personnalisé, `fabienk.github.io/blog-photo`.
- ~~Accès complet au disque pour `/bin/bash`~~ — résolu le 2026-08-27 : accordé par l'auteur, jobs launchd vérifiés fonctionnels (`LastExitStatus = 0`).
- ~~Source de déploiement GitHub Pages~~ — résolu le 2026-08-27 : basculé sur "GitHub Actions" par l'auteur (build_type: workflow confirmé via l'API).
- ~~Compte Twilio / gestion de l'image dans la notification~~ — résolu le 2026-08-27 : Twilio abandonné (blocages répétés), remplacé par email — voir décisions ci-dessus.

## 6. Journal d'avancement

- **2026-08-27** — Lecture de CLAUDE.md, création de ce fichier `etat.md`, correction de `themes.md` (ajout de "Liberté" en tête). Localisation et vérification de l'outil ShowMe5WH (installé et actif sur le Mac mini). Feuille de route en 5 phases définie et validée avec l'auteur.
- **2026-08-27** — Phase 1 : recherche d'idées (symboles de la liberté), rédaction de 3 prompts originaux, génération des 3 photos via l'API REST de ShowMe5WH (modèle Flux.1 Schnell, aucune régénération nécessaire), rédaction des 3 textes, création de la preview brute. Publication rangée dans `publications/2026-08-27-liberte/`. Contenu validé par l'auteur le jour même, sans ajustement.
- **2026-08-27** — Phase 2 : choix de la stack (Astro) et de l'hébergement pressenti (GitHub Pages), construction du site "Prisme" (page d'accueil + page de publication), design éditorial sur mesure (Fraunces/Work Sans, thème clair/sombre), vérifié en local (desktop + mobile). Dépôt git initialisé et premier commit effectué (versioning).
- **2026-08-27** — L'auteur précise que le contenu et la mise en page relèvent entièrement de l'agent (CLAUDE.md) : plus de validation intermédiaire à demander, seule la mise en ligne finale requiert son accord. Ajout du dépôt distant fourni par l'auteur comme remote `origin` (aucun push effectué).
- **2026-08-27** — Phase 3 : écriture de `automation/PIPELINE.md` (procédure hebdomadaire stable), `scripts/run_publication.sh` (déclencheur launchd avec détection de rattrapage et 3 tentatives max) et `scripts/notify_author.sh` (SMS/MMS via l'API Twilio). Vérifications en session : authentification Claude Code par abonnement fonctionnelle en environnement dépouillé type launchd, `--permission-mode acceptEdits` suffisant pour un run sans invite de confirmation, logique anti-doublon testée.
- **2026-08-27** — Réponses de l'auteur : mise en ligne automatique sur réponse affirmative (construit : `check_validation.sh` + `publish.sh` + `.github/workflows/deploy.yml`), pas de domaine personnalisé (`fabienk.github.io/blog-photo`, `astro.config.mjs` mis à jour avec `base`, liens internes du site corrigés en conséquence, build vérifié), nouveaux modèles ShowMe5WH ajoutés par l'auteur utilisables par l'agent. Fusion de l'historique git avec le README initial du dépôt GitHub (remote). Jobs launchd chargés mais initialement bloqués par l'autorisation "Accès complet au disque" macOS.
- **2026-08-27** — L'auteur accorde l'accès complet au disque à `/bin/bash` : les deux jobs launchd sont vérifiés fonctionnels (`LastExitStatus = 0`). L'auteur bascule lui-même la source GitHub Pages sur "GitHub Actions" (ma tentative via l'API avait été refusée par mon propre classifieur de permissions) — confirmé (`build_type: workflow`).
- **2026-08-27** — Tentative de création d'un compte Twilio : blocages répétés (profil de conformité qui ne progresse pas, écran de vérification vide, numéro français acheté mais non activé pour l'envoi — erreur 21659). L'auteur abandonne Twilio et opte pour une notification par email. Réécriture complète du mécanisme de notification/validation : `scripts/notify_author.py` (envoi Gmail SMTP, photo en pièce jointe), `scripts/check_validation.py` + `scripts/gmail_latest_uid.py` (sondage IMAP), `scripts/_email_lib.py` (utilitaires partagés). `run_publication.sh` et `publish.sh` adaptés en conséquence, anciens scripts SMS supprimés. `CLAUDE.md` mis à jour (section Déclenchement automatique) avec l'accord explicite de l'auteur. Job `checkvalidation` rechargé avec le nouveau script Python, vérifié fonctionnel (`LastExitStatus = 0`). Reste : mot de passe d'application Gmail à générer par l'auteur.
