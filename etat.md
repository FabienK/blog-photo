# État du projet — Blog Photo

Fichier de suivi d'avancement, mis à jour à chaque étape significative. Voir [CLAUDE.md](./CLAUDE.md) pour les règles du projet et [themes.md](./themes.md) pour les thèmes restants.

## 1. Phase actuelle

**Phase 1 — Pipeline manuel de bout en bout** (contenu produit le 2026-08-27, en attente de validation de l'auteur)

Phase 0 terminée le 2026-08-27. Les 3 photos + textes de la publication "Liberté" sont générés et la preview brute est prête. Prochaine étape : validation du contenu par l'auteur, puis passage en Phase 2 (stack technique + habillage).

## 2. Décisions prises

| Date | Décision |
|---|---|
| 2026-08-27 | Le thème "Liberté" est inséré en tête de `themes.md` pour être la première publication, conformément à CLAUDE.md (la liste ne le contenait pas initialement). |
| 2026-08-27 | On commence par un pipeline **manuel** de bout en bout (une publication complète, déclenchée à la main, validation dans le chat) avant de construire l'automatisation launchd/Twilio. |
| 2026-08-27 | Stack technique du site : **à décider en Phase 2**, une fois le contenu d'une première publication validé. |

## 3. Publication en cours

Thème : **Liberté** (premier thème, retiré de `themes.md`). Dossier : [publications/2026-08-27-liberte/](./publications/2026-08-27-liberte/) — preview brute : [preview.md](./publications/2026-08-27-liberte/preview.md).

Statut par article :

| Article | Idée | Photo générée | Texte rédigé | Mise en page | Preview | Validation auteur | Tentatives régén. (max 3) |
|---|---|---|---|---|---|---|---|
| 1 — L'instant avant l'envol (colombe/cage) | ✅ | ✅ | ✅ | — (Phase 2) | ✅ | ⏳ en attente | 0 |
| 2 — Le dernier maillon (chaîne brisée, N&B) | ✅ | ✅ | ✅ | — (Phase 2) | ✅ | ⏳ en attente | 0 |
| 3 — Aucune limite (silhouette, falaise) | ✅ | ✅ | ✅ | — (Phase 2) | ✅ | ⏳ en attente | 0 |

## 4. Historique des publications

Aucune publication réalisée à ce jour.

| Date | Thème | Nb articles | Lien preview/archive | Statut |
|---|---|---|---|---|
| — | — | — | — | — |

## 5. Blocages / questions ouvertes

Aucun blocage actuel.

- ~~Localisation de l'outil ShowMe5WH~~ — résolu le 2026-08-27 : trouvé dans `Documents/Projets Claude code/Image generator /Image-generator/`, actuellement installé et démarré (ComfyUI :8188, backend FastAPI :8000, frontend :5173), presets renseignés. API REST disponible (`POST /api/generate`, `POST /api/batches`) pour un déclenchement programmatique.
- ~~Écart thème "Liberté" vs contenu de `themes.md`~~ — résolu le 2026-08-27 : "Liberté" ajouté en tête de liste.

## 6. Journal d'avancement

- **2026-08-27** — Lecture de CLAUDE.md, création de ce fichier `etat.md`, correction de `themes.md` (ajout de "Liberté" en tête). Localisation et vérification de l'outil ShowMe5WH (installé et actif sur le Mac mini). Feuille de route en 5 phases définie et validée avec l'auteur.
- **2026-08-27** — Phase 1 : recherche d'idées (symboles de la liberté), rédaction de 3 prompts originaux, génération des 3 photos via l'API REST de ShowMe5WH (modèle Flux.1 Schnell, aucune régénération nécessaire), rédaction des 3 textes, création de la preview brute. Publication rangée dans `publications/2026-08-27-liberte/`. En attente de validation du contenu par l'auteur avant Phase 2.
