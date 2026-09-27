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
   (`http://127.0.0.1:8540/api/script` puis `/api/generate` — mode d'emploi
   complet dans `Documents/Projets Claude code/ShowMe-5WH/AGENT.md` : lire ce
   seul fichier, lancer `scripts/start_showme.sh` si le backend ne répond pas,
   vérifier `/api/status` avant de générer), rédiger un texte expliquant en
   quoi la photo illustre le thème.
   - Maximum **3 tentatives de régénération par article**. Au-delà, garder la
     meilleure image obtenue plutôt que de boucler.
   - **Chaque appel à `/api/generate` doit être lancé avec un timeout explicite
     d'au moins 600000 ms (10 min, le maximum autorisé par l'outil Bash) —
     jamais le timeout par défaut (2 min).** Une génération dépassant le
     timeout par défaut est automatiquement basculée en arrière-plan par
     l'environnement d'exécution, sans bloquer l'agent : si la réponse se
     termine à ce moment-là, le pipeline s'arrête pour de bon (le mode
     headless ne "réveille" jamais l'agent plus tard pour une notification en
     attente). Ne jamais terminer la réponse tant qu'une génération est en
     cours ou que le marqueur `PREVIEW_DIR:` n'est pas prêt à être écrit — pas
     de formulation du type "j'attendrai la suite plus tard".
4. **Mise en page** — Lire `automation/design-log.md` pour connaître la palette et
   la typographie de la dernière publication. Construire la page de publication
   dans `site/`, avec un design adapté au thème (l'agent décide seul, comme pour
   tout le reste de ce pipeline sauf le thème imposé et la mise en ligne finale —
   voir la répartition des décisions dans `CLAUDE.md`) : choisir une palette de
   couleurs et une typographie qui diffèrent de celles de la dernière entrée du
   log (pas seulement la mise en page — voir `CLAUDE.md` > Garde-fous > Design).
   S'inspirer librement de https://uiverse.io/, https://reactbits.dev/get-started/index
   ou https://kokonutui.com/ si utile, y compris en copiant un composant
   React/Tailwind (ajouter l'intégration Astro correspondante — `@astrojs/react` ou
   `@astrojs/tailwind` — si elle n'est pas déjà présente). Définir la palette/typo de
   la page dans son propre bloc `<style>` scopé (redéfinir les variables CSS de
   `site/src/styles/global.css` via un sélecteur `:global(body)` local à la page,
   sur le modèle de l'override déjà utilisé pour le mode sombre) plutôt que de
   modifier `global.css`, qui reste le thème par défaut de la page d'accueil.
   Ajouter la publication à la page d'accueil, puis ajouter une ligne à
   `automation/design-log.md` décrivant le design choisi (palette, typographie,
   style de mise en page, source d'inspiration éventuelle).
5. **Rangement** — Créer `publications/<date>-<slug-theme>/` avec, pour
   chaque article, `photo.png`, `prompt.txt`, `texte.md`, et un
   `preview.md` à la racine du dossier (image + texte brut, sans habillage —
   c'est la preview envoyée par email, distincte de la page stylée dans `site/`).
6. **État** — Mettre à jour `etat.md` (phase, décisions, statut par article,
   historique, journal).
7. **Arrêt** — S'arrêter ici. Ne pas commiter au-delà d'un commit local
   (versioning), ne rien pousser vers un dépôt distant, ne rien publier en
   ligne. La mise en ligne reste une action manuelle ou explicitement
   déclenchée par l'auteur, jamais automatique.
8. **Marqueur** — Terminer la réponse par une ligne au format exact :
   `PREVIEW_DIR: publications/<date>-<slug-theme>` (chemin relatif à la
   racine du projet), pour que `scripts/run_publication.sh` puisse localiser
   la preview et déclencher la notification email.

## Cas limites

- **`themes.md` vide** : ne rien générer, le laisser à `run_publication.sh`
  (qui détecte ce cas avant même d'invoquer Claude et notifie l'auteur).
- **ShowMe5WH indisponible** (ComfyUI/backend/frontend arrêtés) : ne pas
  tenter de contourner avec un autre générateur d'images (interdit par
  CLAUDE.md). Consigner l'échec dans `etat.md`, terminer sans marqueur
  `PREVIEW_DIR:` — `run_publication.sh` traitera cela comme un échec de
  tentative et notifiera l'auteur après épuisement des 3 tentatives.
