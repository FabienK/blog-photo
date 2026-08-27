# État du projet — Blog Photo

Fichier de suivi d'avancement, mis à jour à chaque étape significative. Voir [CLAUDE.md](./CLAUDE.md) pour les règles du projet et [themes.md](./themes.md) pour les thèmes restants.

## 1. Phase actuelle

**Phase 3 — Automatisation** (scripts et job launchd construits le 2026-08-27, non activés)

Phases 0 à 2 terminées le 2026-08-27. **Note de méthode (2026-08-27)** : l'auteur a précisé que le contenu (photos/prompts/textes) et la mise en page ne nécessitent pas de validation intermédiaire — seule la mise en ligne finale requiert son accord explicite (conforme à CLAUDE.md). À partir de maintenant, ces étapes sont exécutées puis rapportées, sans être présentées comme des questions.

Scripts d'automatisation (`scripts/run_publication.sh`, `scripts/notify_author.sh`, `automation/PIPELINE.md`, `automation/*.plist`) écrits et testés partiellement (voir `automation/AUTOMATISATION.md` pour le détail). Le job launchd n'est **pas encore chargé** dans le système (activation = changement permanent, à valider explicitement) et le compte Twilio n'existe pas encore (l'auteur doit le créer — hors périmètre de l'agent). **Aucune mise en ligne publique n'a eu lieu** — le site tourne uniquement en local.

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

**Bloquants pour activer l'automatisation (nécessitent l'auteur, hors périmètre agent) :**

1. Créer un compte Twilio, acheter un numéro, renseigner `.env` (voir `.env.example` et `automation/AUTOMATISATION.md`).
2. Décider comment gérer l'image dans le SMS (texte seul par défaut, ou joindre une photo — ce qui suppose de l'exposer sur une URL publique, donc une forme de mise en ligne à valider explicitement).
3. Décider, avant de construire cette brique, ce que doit déclencher une réponse positive au SMS : simple information pour que l'auteur publie lui-même, ou déclenchement automatique par l'agent (non construit à ce stade — touche directement au garde-fou "mise en ligne").
4. Donner le feu vert explicite pour charger le job launchd (`launchctl load`, voir `automation/AUTOMATISATION.md`) — installation d'une automatisation permanente, distincte des décisions de contenu/design.
5. Donner le feu vert explicite pour le premier `git push` vers [github.com/FabienK/blog-photo](https://github.com/FabienK/blog-photo.git) (et pour activer GitHub Pages dessus le cas échéant).

**Résolus :**

- ~~Localisation de l'outil ShowMe5WH~~ — résolu le 2026-08-27 : trouvé dans `Documents/Projets Claude code/Image generator /Image-generator/`, actuellement installé et démarré (ComfyUI :8188, backend FastAPI :8000, frontend :5173), presets renseignés. API REST disponible (`POST /api/generate`, `POST /api/batches`) pour un déclenchement programmatique.
- ~~Écart thème "Liberté" vs contenu de `themes.md`~~ — résolu le 2026-08-27 : "Liberté" ajouté en tête de liste.
- ~~Dépôt GitHub pour l'hébergement~~ — résolu le 2026-08-27 : fourni par l'auteur, ajouté comme remote (pas encore poussé).

## 6. Journal d'avancement

- **2026-08-27** — Lecture de CLAUDE.md, création de ce fichier `etat.md`, correction de `themes.md` (ajout de "Liberté" en tête). Localisation et vérification de l'outil ShowMe5WH (installé et actif sur le Mac mini). Feuille de route en 5 phases définie et validée avec l'auteur.
- **2026-08-27** — Phase 1 : recherche d'idées (symboles de la liberté), rédaction de 3 prompts originaux, génération des 3 photos via l'API REST de ShowMe5WH (modèle Flux.1 Schnell, aucune régénération nécessaire), rédaction des 3 textes, création de la preview brute. Publication rangée dans `publications/2026-08-27-liberte/`. Contenu validé par l'auteur le jour même, sans ajustement.
- **2026-08-27** — Phase 2 : choix de la stack (Astro) et de l'hébergement pressenti (GitHub Pages), construction du site "Prisme" (page d'accueil + page de publication), design éditorial sur mesure (Fraunces/Work Sans, thème clair/sombre), vérifié en local (desktop + mobile). Dépôt git initialisé et premier commit effectué (versioning).
- **2026-08-27** — L'auteur précise que le contenu et la mise en page relèvent entièrement de l'agent (CLAUDE.md) : plus de validation intermédiaire à demander, seule la mise en ligne finale requiert son accord. Ajout du dépôt distant fourni par l'auteur comme remote `origin` (aucun push effectué).
- **2026-08-27** — Phase 3 : écriture de `automation/PIPELINE.md` (procédure hebdomadaire stable), `scripts/run_publication.sh` (déclencheur launchd avec détection de rattrapage et 3 tentatives max) et `scripts/notify_author.sh` (SMS/MMS via l'API Twilio). Vérifications en session : authentification Claude Code par abonnement fonctionnelle en environnement dépouillé type launchd, `--permission-mode acceptEdits` suffisant pour un run sans invite de confirmation, logique anti-doublon testée. Job launchd écrit (`automation/com.fabien.blogphoto.publication.plist`) mais **non chargé**. Compte Twilio pas encore créé (bloquant côté auteur). Détail complet et checklist restante dans `automation/AUTOMATISATION.md`.
