# État du projet — Blog Photo

Fichier de suivi d'avancement, mis à jour à chaque étape significative. Voir [CLAUDE.md](./CLAUDE.md) pour les règles du projet et [themes.md](./themes.md) pour les thèmes restants.

## 1. Phase actuelle

**Phase 3 — Automatisation** (mécanisme complet construit le 2026-08-27, jobs launchd chargés mais bloqués par une autorisation macOS)

Phases 0 à 2 terminées le 2026-08-27. **Note de méthode (2026-08-27)** : l'auteur a précisé que le contenu (photos/prompts/textes) et la mise en page ne nécessitent pas de validation intermédiaire — seule la mise en ligne finale requiert son accord explicite (conforme à CLAUDE.md). À partir de maintenant, ces étapes sont exécutées puis rapportées, sans être présentées comme des questions.

Le cycle complet (génération → SMS preview → réponse affirmative → mise en ligne automatique) est construit : `scripts/run_publication.sh`, `scripts/check_validation.sh`, `scripts/publish.sh`, `.github/workflows/deploy.yml`. Les deux jobs launchd sont **chargés** (`launchctl load` fait), mais échouent actuellement (`Operation not permitted`) faute d'accès complet au disque accordé à `/bin/bash` — autorisation macOS que l'auteur doit accorder lui-même. Compte Twilio pas encore créé. **Aucune mise en ligne publique n'a eu lieu** — le site tourne uniquement en local. Détail complet et checklist restante dans [automation/AUTOMATISATION.md](./automation/AUTOMATISATION.md).

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
| 2026-08-27 | Mise en ligne automatique sur réponse SMS affirmative (oui/je valide/ok/go/d'accord) : décision explicite de l'auteur. `check_validation.sh` sonde les réponses toutes les 10 min et déclenche `publish.sh` (push + déploiement GitHub Pages) sans repasser par le chat. |
| 2026-08-27 | Pas de nom de domaine personnalisé pour GitHub Pages (achat payant, hors gratuité) : URL retenue `https://fabienk.github.io/blog-photo/`. `astro.config.mjs` configuré avec `base: '/blog-photo'`. |
| 2026-08-27 | Compte Twilio : un seul compte suffit, réutilisable pour d'autres projets de l'auteur (pas besoin d'un compte dédié par projet). |
| 2026-08-27 | Si l'auteur ajoute lui-même un nouveau modèle/checkpoint à ShowMe5WH (`presets.json`), l'agent peut l'utiliser normalement — le garde-fou CLAUDE.md interdit à l'agent d'installer des modèles lui-même, pas d'utiliser ceux ajoutés par l'auteur. |

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

**Bloquants actuels (nécessitent l'auteur, hors périmètre agent) — détail dans `automation/AUTOMATISATION.md` :**

1. **Accès complet au disque pour `/bin/bash`** (Réglages Système → Confidentialité et sécurité → Accès complet au disque) — sans ça, les deux jobs launchd échouent à chaque déclenchement (`Operation not permitted`, confirmé en testant leur premier run).
2. Créer un compte Twilio, acheter un numéro, renseigner `.env`.
3. Activer "GitHub Actions" comme source de déploiement sur Settings → Pages du dépôt (actuellement en mode "legacy", incompatible avec le workflow construit) — tentative de bascule automatique refusée par mon propre classifieur de permissions (changement de réglage de compte).
4. Décider comment gérer l'image dans le SMS (texte seul par défaut, ou joindre une photo — ce qui suppose de l'exposer sur une URL publique, donc une forme de mise en ligne distincte à valider le moment venu).

**Résolus :**

- ~~Localisation de l'outil ShowMe5WH~~ — résolu le 2026-08-27 : trouvé dans `Documents/Projets Claude code/Image generator /Image-generator/`, actuellement installé et démarré (ComfyUI :8188, backend FastAPI :8000, frontend :5173), presets renseignés. API REST disponible (`POST /api/generate`, `POST /api/batches`) pour un déclenchement programmatique.
- ~~Écart thème "Liberté" vs contenu de `themes.md`~~ — résolu le 2026-08-27 : "Liberté" ajouté en tête de liste.
- ~~Dépôt GitHub pour l'hébergement~~ — résolu le 2026-08-27 : fourni par l'auteur, ajouté comme remote (pas encore poussé).
- ~~Ce que déclenche la réponse SMS~~ — résolu le 2026-08-27 : réponse affirmative = mise en ligne automatique, mécanisme construit (`check_validation.sh` / `publish.sh`).
- ~~Feu vert pour charger le job launchd~~ — résolu le 2026-08-27 : chargé (bloqué par l'autorisation macOS ci-dessus).
- ~~Nom de domaine GitHub Pages~~ — résolu le 2026-08-27 : pas de domaine personnalisé, `fabienk.github.io/blog-photo`.

## 6. Journal d'avancement

- **2026-08-27** — Lecture de CLAUDE.md, création de ce fichier `etat.md`, correction de `themes.md` (ajout de "Liberté" en tête). Localisation et vérification de l'outil ShowMe5WH (installé et actif sur le Mac mini). Feuille de route en 5 phases définie et validée avec l'auteur.
- **2026-08-27** — Phase 1 : recherche d'idées (symboles de la liberté), rédaction de 3 prompts originaux, génération des 3 photos via l'API REST de ShowMe5WH (modèle Flux.1 Schnell, aucune régénération nécessaire), rédaction des 3 textes, création de la preview brute. Publication rangée dans `publications/2026-08-27-liberte/`. Contenu validé par l'auteur le jour même, sans ajustement.
- **2026-08-27** — Phase 2 : choix de la stack (Astro) et de l'hébergement pressenti (GitHub Pages), construction du site "Prisme" (page d'accueil + page de publication), design éditorial sur mesure (Fraunces/Work Sans, thème clair/sombre), vérifié en local (desktop + mobile). Dépôt git initialisé et premier commit effectué (versioning).
- **2026-08-27** — L'auteur précise que le contenu et la mise en page relèvent entièrement de l'agent (CLAUDE.md) : plus de validation intermédiaire à demander, seule la mise en ligne finale requiert son accord. Ajout du dépôt distant fourni par l'auteur comme remote `origin` (aucun push effectué).
- **2026-08-27** — Phase 3 : écriture de `automation/PIPELINE.md` (procédure hebdomadaire stable), `scripts/run_publication.sh` (déclencheur launchd avec détection de rattrapage et 3 tentatives max) et `scripts/notify_author.sh` (SMS/MMS via l'API Twilio). Vérifications en session : authentification Claude Code par abonnement fonctionnelle en environnement dépouillé type launchd, `--permission-mode acceptEdits` suffisant pour un run sans invite de confirmation, logique anti-doublon testée.
- **2026-08-27** — Réponses de l'auteur : mise en ligne automatique sur réponse SMS affirmative (construit : `check_validation.sh` + `publish.sh` + `.github/workflows/deploy.yml`), pas de domaine personnalisé (`fabienk.github.io/blog-photo`, `astro.config.mjs` mis à jour avec `base`, liens internes du site corrigés en conséquence, build vérifié), un seul compte Twilio suffit, nouveaux modèles ShowMe5WH ajoutés par l'auteur utilisables par l'agent. Fusion de l'historique git avec le README initial du dépôt GitHub (remote). Les deux jobs launchd ont été chargés (`launchctl load`) mais échouent au démarrage (`Operation not permitted`, LastExitStatus 32256) : bloqués par l'autorisation "Accès complet au disque" macOS à accorder à `/bin/bash`, que je ne peux pas accorder moi-même. Tentative d'activer "GitHub Actions" comme source GitHub Pages via l'API refusée par mon classifieur de permissions (changement de réglage de compte) — à faire par l'auteur. Détail complet et checklist restante dans `automation/AUTOMATISATION.md`.
