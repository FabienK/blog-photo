# Blog Photo — Contexte projet

## Objectif
Blog photo avec une publication automatisée chaque **dimanche à 14h**.
Première publication : thème "la liberté".
Mise en ligne uniquement après validation par un tiers (modalité à définir — voir Questions ouvertes).

## Structure d'une publication
- Entre 1 et 5 articles par publication
- 1 seul article = exception, pas la norme
- Design décidé par l'agent, celui qui lui semble le mieux adapté au thème
- Titre de la publication = le thème lui-même

## Structure d'un article
Chaque article doit contenir :
1. Une photo générée + son prompt de génération
2. Un texte expliquant en quoi la photo illustre le thème
3. Une mise en page qui valorise l'article
4. Le nom du modèle de génération utilisé (mention obligatoire)

## Gestion des thèmes
- Les thèmes ne sont pas choisis par l'agent : ils sont imposés, listés dans un fichier `themes.md` rempli par l'auteur
- À chaque publication, l'agent lit le premier thème de la liste, le met en mémoire pour la publication en cours, puis le supprime de `themes.md`
- Le thème lu devient le titre de la publication

## Outils identifiés
- Recherche web libre pour trouver des idées liées au thème
- Génération d'images : **ShowMe5WH** (anciennement 4W1H), outil local, à utiliser dans sa version actuelle uniquement
- Design : compétences natives Anthropic (Claude) + ressources web

## Répartition des décisions

**L'agent décide seul de :**
- Photos générées, prompts, design (adapté au thème imposé), mise en page
- Public visé
- Recherche d'idées et de références
- Rédaction des textes
- Stack technique du blog (générateur de site, hébergement, etc.), sous contrainte impérative de gratuité

**Imposé, hors décision de l'agent :**
- Le thème de chaque publication, tiré de `themes.md` (voir Gestion des thèmes)

**L'agent ne décide jamais seul de :**
- La mise en ligne finale → validation explicite de l'auteur obligatoire avant publication

## Garde-fous

### Mise en ligne
- Aucune publication (ni mise à jour d'une publication existante) sans accord explicite préalable de l'auteur
- L'agent doit produire un livrable de preview consultable (aperçu complet de la publication) avant de demander cet accord
- Pas d'accès aux identifiants/API de mise en ligne : cette étape reste une action manuelle ou déclenchée explicitement par l'auteur

### Outil de génération d'images (ShowMe5WH)
- Utilisation en l'état uniquement : aucune modification du pipeline, du workflow, de la configuration
- Interdiction d'acquérir, télécharger ou installer de nouveaux modèles
- Interdiction d'appeler un service de génération d'images externe/tiers en remplacement ou complément

### Périmètre d'action
- L'agent ne modifie pas ce fichier de contexte (CLAUDE.md) ni sa propre configuration sans validation de l'auteur
- Écriture limitée au dossier du projet — aucune action en dehors
- Pas d'usage de contenus protégés trouvés sur le web (images, textes) comme matière finale — uniquement comme source d'inspiration/idées

### Fiabilité et budget
- Nombre limité de tentatives de régénération par article (éviter les boucles de génération infinies)
- Conserver un historique/versioning des publications et de leurs preview pour permettre un retour en arrière

## Déclenchement automatique
- Mécanisme retenu : **launchd** (macOS) programmé pour dimanche 14h, sur le Mac mini où tourne ShowMe5WH
- Lance un script qui invoque Claude Code en mode non-interactif avec le contexte du projet
- L'agent exécute tout le pipeline jusqu'à la preview, puis s'arrête et attend l'accord de l'auteur (voir garde-fous)
- Si le Mac est éteint/endormi le dimanche à 14h : rattrapage automatique au prochain démarrage de la machine
- En cas d'échec pendant la génération : retry automatique (dans la limite du nombre max de tentatives, à définir)
- Notification de fin de preview : **email** (Gmail SMTP/IMAP, photo en pièce jointe) — gratuit. Twilio/SMS abandonné le 2026-08-27 (procédure d'inscription/conformité bloquante, voir etat.md)
- Validation de la mise en ligne : réponse affirmative à l'email reçu ("oui", "je valide", "ok", "go", "d'accord" en début de message) déclenche la mise en ligne automatique — décision explicite de l'auteur le 2026-08-27
- Nombre max de tentatives de régénération par article : 3
- Format de la preview : image + texte brut, sans mise en habillage/mise en page (l'habillage n'intervient qu'à la publication finale)

## Attentes de comportement

- **Agir dès qu'un blocage saute**, sans attendre une relance explicite : si une condition de déclenchement est déjà remplie (ex. mot de passe fourni alors qu'on est après 14h le dimanche), enchaîner sur l'étape suivante plutôt que de s'arrêter et attendre une nouvelle demande — sauf si cette étape suivante nécessite elle-même un accord explicite (mise en ligne, voir garde-fous).
- **Vérifier le résultat des actions asynchrones/automatiques** (job launchd, déploiement GitHub Pages, envoi d'email) au lieu de considérer la tâche terminée dès qu'elle est déclenchée : contrôler les logs et/ou le site en ligne avant de conclure au succès, sans attendre que l'auteur signale un problème.

(Décision de l'auteur le 2026-08-30, suite à un cas concret où ces deux points n'avaient pas été respectés — voir `etat.md`, journal du 2026-08-30.)

## Questions ouvertes
Aucune pour l'instant.
