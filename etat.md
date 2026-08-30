# État du projet — Blog Photo

Fichier de suivi d'avancement, mis à jour à chaque étape significative. Voir [CLAUDE.md](./CLAUDE.md) pour les règles du projet et [themes.md](./themes.md) pour les thèmes restants.

## 1. Phase actuelle

**Phase 3 — Automatisation** (mécanisme complet et fonctionnel, cycle de bout en bout opérationnel)

Phases 0 à 2 terminées le 2026-08-27. **Note de méthode (2026-08-27)** : l'auteur a précisé que le contenu (photos/prompts/textes) et la mise en page ne nécessitent pas de validation intermédiaire — seule la mise en ligne finale requiert son accord explicite (conforme à CLAUDE.md). À partir de maintenant, ces étapes sont exécutées puis rapportées, sans être présentées comme des questions.

Le cycle complet (génération → email preview → réponse affirmative → mise en ligne automatique) est construit : `scripts/run_publication.sh`, `scripts/check_validation.py`, `scripts/publish.sh`, `.github/workflows/deploy.yml`. Les deux jobs launchd sont **chargés et fonctionnels** (`LastExitStatus = 0`, autorisation macOS accordée). Twilio abandonné le 2026-08-27 (procédure d'inscription bloquante) au profit d'une notification par **email** (Gmail SMTP/IMAP) — voir CLAUDE.md, section Déclenchement automatique. Mot de passe d'application Gmail renseigné et testé le 2026-08-30 (connexion SMTP + IMAP validée) : plus aucun point bloquant. Première publication ("Liberté") déjà en ligne depuis le 2026-08-28. Détail complet dans [automation/AUTOMATISATION.md](./automation/AUTOMATISATION.md).

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

Thème : **Élégance** (2e thème, retiré de `themes.md`). Dossier : [publications/2026-08-30-elegance/](./publications/2026-08-30-elegance/) — preview brute : [preview.md](./publications/2026-08-30-elegance/preview.md). Déclenchement manuel dans le chat (rattrapage du dimanche 30/08 14h), pipeline `automation/PIPELINE.md` suivi à l'identique.

Statut par article :

| Article | Idée | Photo générée | Texte rédigé | Mise en page | Preview | Validation contenu (Phase 1) | Validation mise en ligne (Phase 3+) | Tentatives régén. (max 3) |
|---|---|---|---|---|---|---|---|---|
| 1 — Le geste suspendu (main de danseuse) | ✅ | ✅ | ✅ | ✅ | ✅ | n/a (plus de validation intermédiaire depuis le 2026-08-27) | ⏳ en attente | 0 |
| 2 — Le pli parfait (drapé de soie) | ✅ | ✅ | ✅ | ✅ | ✅ | n/a | ⏳ en attente | 0 |
| 3 — Le rituel du thé (versement, mains) | ✅ | ✅ | ✅ | ✅ | ✅ | n/a | ⏳ en attente | 0 |

Note technique : réponse `image_base64` de l'API ShowMe5WH reçue avec préfixe `data:image/png;base64,` — décodage adapté en conséquence (script de génération ponctuel, non committé, dans le scratchpad de session).

Site local consultable en dev : `npm --prefix site run dev` puis `http://localhost:4321/elegance` (page d'accueil : `http://localhost:4321/`). Build de production vérifié sans erreur (3 pages générées).

## 4. Historique des publications

| Date | Thème | Nb articles | Lien preview/archive | Statut |
|---|---|---|---|---|
| 2026-08-27 | Liberté | 3 | [publications/2026-08-27-liberte/](./publications/2026-08-27-liberte/) | ✅ en ligne — https://fabienk.github.io/blog-photo/liberte/ |

## 5. Blocages / questions ouvertes

**Aucun blocage actuel.**

**Résolus :**

- ~~Mot de passe d'application Gmail~~ — résolu le 2026-08-30 : généré par l'auteur ([myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)), renseigné dans `.env`, connexion SMTP et IMAP testée avec succès. Premier mot de passe collé rejeté (`535 Bad Credentials`) — probablement une erreur de copie ou compte sans validation en 2 étapes active au moment de la génération ; régénéré et validé.
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
- **2026-08-30** — Mise en ligne automatique de la publication "elegance" suite à validation par email : https://fabienk.github.io/blog-photo/elegance/
- **2026-08-30** — Correction d'un oubli : "Liberté" n'avait jamais été retiré de `themes.md` après sa lecture le 2026-08-27 (l'étape 1 du pipeline avait été suivie en esprit mais pas exécutée littéralement sur le fichier). Retiré maintenant, avec "Élégance" (thème de cette publication).
- **2026-08-30** — Déclenchement manuel de la publication hebdomadaire (rattrapage du dimanche 14h, demandé par l'auteur dans le chat). Thème lu et retiré de `themes.md` : "Élégance". Recherche d'angles, 3 prompts originaux, génération des 3 photos via l'API REST de ShowMe5WH (Flux.1 Schnell, aucune régénération nécessaire — décodage base64 adapté au format `data:image/png;base64,...` renvoyé par l'API), rédaction des 3 textes, rangement dans `publications/2026-08-30-elegance/` (preview brute incluse). Mise en page dédiée créée dans `site/` (`elegance.astro`), design distinct de "Liberté" (titres italiques centrés, composition plus aérée) mais cohérent avec l'identité graphique du site ; page d'accueil mise à jour. Build de production vérifié sans erreur, rendu contrôlé dans le navigateur (page publication + accueil). Pipeline arrêté à la preview conformément au garde-fou CLAUDE.md — en attente de l'accord de l'auteur pour la mise en ligne.

- **2026-08-30** — Mot de passe d'application Gmail renseigné par l'auteur dans `.env`. Premier essai rejeté par Google (`535 Bad Credentials`) ; l'auteur en a régénéré un second, validé cette fois (connexion SMTP `smtp.gmail.com:587` et IMAP `imap.gmail.com` testées avec succès). Le cycle d'automatisation Phase 3 est désormais entièrement fonctionnel, plus aucun point bloquant.

- **2026-08-28** — Mise en ligne automatique de la publication "Liberté" suite à validation par email : https://fabienk.github.io/blog-photo/liberte/

- **2026-08-27** — Lecture de CLAUDE.md, création de ce fichier `etat.md`, correction de `themes.md` (ajout de "Liberté" en tête). Localisation et vérification de l'outil ShowMe5WH (installé et actif sur le Mac mini). Feuille de route en 5 phases définie et validée avec l'auteur.
- **2026-08-27** — Phase 1 : recherche d'idées (symboles de la liberté), rédaction de 3 prompts originaux, génération des 3 photos via l'API REST de ShowMe5WH (modèle Flux.1 Schnell, aucune régénération nécessaire), rédaction des 3 textes, création de la preview brute. Publication rangée dans `publications/2026-08-27-liberte/`. Contenu validé par l'auteur le jour même, sans ajustement.
- **2026-08-27** — Phase 2 : choix de la stack (Astro) et de l'hébergement pressenti (GitHub Pages), construction du site "Prisme" (page d'accueil + page de publication), design éditorial sur mesure (Fraunces/Work Sans, thème clair/sombre), vérifié en local (desktop + mobile). Dépôt git initialisé et premier commit effectué (versioning).
- **2026-08-27** — L'auteur précise que le contenu et la mise en page relèvent entièrement de l'agent (CLAUDE.md) : plus de validation intermédiaire à demander, seule la mise en ligne finale requiert son accord. Ajout du dépôt distant fourni par l'auteur comme remote `origin` (aucun push effectué).
- **2026-08-27** — Phase 3 : écriture de `automation/PIPELINE.md` (procédure hebdomadaire stable), `scripts/run_publication.sh` (déclencheur launchd avec détection de rattrapage et 3 tentatives max) et `scripts/notify_author.sh` (SMS/MMS via l'API Twilio). Vérifications en session : authentification Claude Code par abonnement fonctionnelle en environnement dépouillé type launchd, `--permission-mode acceptEdits` suffisant pour un run sans invite de confirmation, logique anti-doublon testée.
- **2026-08-27** — Réponses de l'auteur : mise en ligne automatique sur réponse affirmative (construit : `check_validation.sh` + `publish.sh` + `.github/workflows/deploy.yml`), pas de domaine personnalisé (`fabienk.github.io/blog-photo`, `astro.config.mjs` mis à jour avec `base`, liens internes du site corrigés en conséquence, build vérifié), nouveaux modèles ShowMe5WH ajoutés par l'auteur utilisables par l'agent. Fusion de l'historique git avec le README initial du dépôt GitHub (remote). Jobs launchd chargés mais initialement bloqués par l'autorisation "Accès complet au disque" macOS.
- **2026-08-27** — L'auteur accorde l'accès complet au disque à `/bin/bash` : les deux jobs launchd sont vérifiés fonctionnels (`LastExitStatus = 0`). L'auteur bascule lui-même la source GitHub Pages sur "GitHub Actions" (ma tentative via l'API avait été refusée par mon propre classifieur de permissions) — confirmé (`build_type: workflow`).
- **2026-08-27** — Tentative de création d'un compte Twilio : blocages répétés (profil de conformité qui ne progresse pas, écran de vérification vide, numéro français acheté mais non activé pour l'envoi — erreur 21659). L'auteur abandonne Twilio et opte pour une notification par email. Réécriture complète du mécanisme de notification/validation : `scripts/notify_author.py` (envoi Gmail SMTP, photo en pièce jointe), `scripts/check_validation.py` + `scripts/gmail_latest_uid.py` (sondage IMAP), `scripts/_email_lib.py` (utilitaires partagés). `run_publication.sh` et `publish.sh` adaptés en conséquence, anciens scripts SMS supprimés. `CLAUDE.md` mis à jour (section Déclenchement automatique) avec l'accord explicite de l'auteur. Job `checkvalidation` rechargé avec le nouveau script Python, vérifié fonctionnel (`LastExitStatus = 0`). Reste : mot de passe d'application Gmail à générer par l'auteur.
