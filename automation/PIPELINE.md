# Pipeline de publication hebdomadaire

Procédure suivie par Claude Code à chaque exécution automatique (déclenchée
par `scripts/run_publication.sh` via launchd, dimanche 14h ou au rattrapage).
Complète `CLAUDE.md` (règles et garde-fous) sans le remplacer — en cas de
divergence, `CLAUDE.md` fait foi.

## Étapes

1. **Thème** — Lire la première ligne de `themes.md`, la mettre en mémoire
   comme thème de cette publication, puis la retirer du fichier.
2. **Idées** — Recherche web libre pour trouver des angles d'interprétation
   du thème (symboles, représentations visuelles), en évitant les clichés
   déjà utilisés dans une publication précédente (voir section 4 d'`etat.md`).
3. **Articles** — Décider du nombre d'articles (entre 1 et 5 ; 1 seul article
   reste une exception, pas la norme). Pour chacun : écrire un prompt de
   génération original, générer la photo via l'API REST de ShowMe5WH
   (`http://127.0.0.1:8000/api/script` puis `/api/generate` — voir
   `Documents/Projets Claude code/Image generator /Image-generator/README.md`
   pour le détail de l'API), rédiger un texte expliquant en quoi la photo
   illustre le thème.
   - Maximum **3 tentatives de régénération par article**. Au-delà, garder la
     meilleure image obtenue plutôt que de boucler.
4. **Mise en page** — Construire la page de publication dans `site/`, avec un
   design adapté au thème (l'agent décide seul, comme pour tout le reste de
   ce pipeline sauf le thème imposé et la mise en ligne finale — voir la
   répartition des décisions dans `CLAUDE.md`). Ajouter la publication à la
   page d'accueil.
5. **Rangement** — Créer `publications/<date>-<slug-theme>/` avec, pour
   chaque article, `photo.png`, `prompt.txt`, `texte.md`, et un
   `preview.md` à la racine du dossier (image + texte brut, sans habillage —
   c'est la preview envoyée par SMS, distincte de la page stylée dans `site/`).
6. **État** — Mettre à jour `etat.md` (phase, décisions, statut par article,
   historique, journal).
7. **Arrêt** — S'arrêter ici. Ne pas commiter au-delà d'un commit local
   (versioning), ne rien pousser vers un dépôt distant, ne rien publier en
   ligne. La mise en ligne reste une action manuelle ou explicitement
   déclenchée par l'auteur, jamais automatique.
8. **Marqueur** — Terminer la réponse par une ligne au format exact :
   `PREVIEW_DIR: publications/<date>-<slug-theme>` (chemin relatif à la
   racine du projet), pour que `scripts/run_publication.sh` puisse localiser
   la preview et déclencher la notification SMS.

## Cas limites

- **`themes.md` vide** : ne rien générer, le laisser à `run_publication.sh`
  (qui détecte ce cas avant même d'invoquer Claude et notifie l'auteur).
- **ShowMe5WH indisponible** (ComfyUI/backend/frontend arrêtés) : ne pas
  tenter de contourner avec un autre générateur d'images (interdit par
  CLAUDE.md). Consigner l'échec dans `etat.md`, terminer sans marqueur
  `PREVIEW_DIR:` — `run_publication.sh` traitera cela comme un échec de
  tentative et notifiera l'auteur après épuisement des 3 tentatives.
