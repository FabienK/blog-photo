# Patron — Pipeline de publication périodique autonome

## Pourquoi ce fichier

Ce projet ("Blog Photo") a été construit par itérations, avec de vrais bugs découverts en
production : authentification headless cassée, permissions insuffisantes, regex fragile,
race condition git, base64 mal formé, plist secret confondu avec plist versionné. Aucun
n'était imprévisible — tous relèvent d'une même famille de pièges propre à *"un agent qui
doit tourner seul, périodiquement, sans humain devant l'écran, jusqu'à un point de blocage
volontaire"*.

Ce fichier extrait ce qui est **invariant** dans ce genre de projet (le tronc, les branches)
de ce qui est **spécifique au blog photo** (les feuilles). Il sert de base à instancier une
variante — blog littéraire, blog de recettes, veille automatisée, etc. — sans retraverser les
mêmes erreurs. Il n'est pas une doc du projet actuel (voir `CLAUDE.md`, `automation/AUTOMATISATION.md`,
`etat.md` pour ça) : c'est le document que j'aurais dû avoir *avant* de commencer.

---

## I. Le tronc — l'invariant

Un agent produit, **sans supervision continue**, du contenu périodique sur un sujet **imposé
par une source externe** (pas choisi par l'agent), jusqu'à un état de **preview consultable**,
puis s'arrête et attend une **validation humaine explicite et asynchrone** avant toute action
visible de l'extérieur (mise en ligne, envoi, publication).

Trois décisions structurent tout le reste :
1. **Ce qui est imposé** (le sujet/thème) n'est **jamais** choisi par l'agent — il est lu dans
   une source externe versionnée, consommée en FIFO.
2. **Ce qui est créatif** (contenu, forme, mise en page, choix techniques) est **entièrement**
   délégué à l'agent, sans validation préalable — sinon l'automatisation perd son intérêt.
3. **Ce qui est irréversible ou visible publiquement** (mise en ligne, envoi externe) **ne se
   déclenche jamais sans un accord humain explicite**, recueilli de façon asynchrone (l'humain
   n'est pas devant l'écran au moment où l'agent tourne).

Tout le reste — launchd, email, git, structure de fichiers — n'est qu'une façon parmi
d'autres d'implémenter ces trois règles.

---

## II. Les branches — architecture réutilisable

### II.1 Cycle de vie invariant

```
déclenchement périodique (avec rattrapage si la machine était éteinte)
        │
        ▼
sujet suivant lu depuis la source externe, PUIS retiré de cette source
        │
        ▼
génération headless (budget de tentatives limité, échec = notification, pas de boucle infinie)
        │
        ▼
preview brute produite et sauvegardée sur disque (pas de mise en habillage à ce stade)
        │
        ▼
notification asynchrone à l'humain (canal choisi selon contraintes de gratuité/fiabilité)
        │
        ▼
attente passive : sondage périodique d'une réponse, pas de blocage actif du process
        │
        ▼
réponse positive détectée (mots-clés explicites) → mise en ligne automatique + confirmation
réponse absente/négative → rien ne se passe, attente indéfinie
```

Le point de bascule "irréversible" doit être **le plus tardif possible** dans ce schéma —
tout ce qui précède peut échouer et être rejoué sans conséquence externe.

### II.2 Composants et leur rôle

| Composant | Rôle | Invariant à respecter |
|---|---|---|
| Déclencheur périodique | Lance le pipeline même si la machine était éteinte/endormie au moment prévu | Rattrapage au prochain démarrage, jamais de double-run pour la même période (fichier d'état `last_run`) |
| Source de sujets | Fournit le sujet imposé de la prochaine publication | Externe à l'agent, modifiable seulement par l'auteur, consommée en FIFO, jamais réinjectée |
| Génération headless | Produit le contenu via l'outil CLI de l'agent en mode non-interactif | Voir section IV — c'est la partie la plus piégeuse de tout le patron. Timeout explicite sur chaque appel long (jamais le défaut de l'outil, voir IV.9) |
| Preview | Livrable consultable avant accord | Format brut (texte + média, pas de mise en habillage) — l'habillage final n'a de sens qu'après validation, pour ne pas le refaire si le contenu change |
| Notification | Signale à l'humain qu'une preview attend une décision | Canal asynchrone, gratuit, capable de porter un aperçu (média en pièce jointe idéalement) |
| Sondage de validation | Détecte la réponse humaine sans bloquer de process en continu | Polling léger et peu fréquent (pas de connexion permanente coûteuse), mots-clés de validation explicites et documentés, insensibles à la casse |
| Mise en ligne | Rend le contenu public | Déclenchée uniquement par le sondage de validation sur détection positive — jamais directement par l'étape de génération |
| État et historique | Permet un retour en arrière, empêche les doublons | Un fichier d'état minimal par mécanisme (dernier run, validation en attente) + un historique versionné de chaque publication produite |
| Logs | Permettent un diagnostic sans re-belle génération | Un fichier de log lisible en continu + sortie brute structurée (JSON si possible) de chaque tentative, pas juste un résumé |

### II.3 Emplacement des fichiers et des secrets

- Le **projet** (dépôt versionné) ne contient **jamais** de secret en clair : jetons, mots de
  passe, clés d'API. Un `.env.example` (gabarit) peut être versionné ; le `.env` réel est
  ignoré par git.
- Le **déclencheur système** (launchd/cron) vit **hors du dépôt** dans son emplacement
  standard (`~/Library/LaunchAgents/` sur macOS). C'est là, et *seulement* là, que peut vivre
  un secret nécessaire à l'invocation (ex. jeton d'authentification headless), dans une
  variable d'environnement du job.
- **Si une copie de ce fichier système est aussi versionnée dans le projet** (pour la relire /
  la faire évoluer), elle doit rester volontairement dépourvue de secret, et il faut décider
  et documenter dès le premier jour **laquelle des deux copies fait foi** — voir IV, "plist
  déployé vs plist versionné".

### II.4 Garde-fous invariants (à formaliser dans le CLAUDE.md / équivalent dès le départ)

- Répartition explicite des décisions en trois colonnes : *décidé seul par l'agent*, *imposé,
  hors décision de l'agent*, *jamais décidé seul par l'agent*.
- Écriture limitée au dossier du projet (+ l'emplacement standard du déclencheur système, s'il
  y a lieu, explicitement listé comme seule exception).
- Contrainte de gratuité si c'est un projet personnel — la formuler comme contrainte dure, pas
  comme préférence, sinon un outil freemium finira par y entrer par la porte de service.
- Aucune modification du fichier de contexte/config de l'agent lui-même sans validation
  explicite de l'auteur (sinon l'agent peut réviser silencieusement ses propres règles).
- Budget de tentatives limité pour toute étape génération (éviter les boucles de
  régénération infinies et les coûts associés).
- Historique/versioning conservé pour permettre un retour en arrière sur n'importe quelle
  publication passée.
- Si un outil de génération de contenu tiers/local est utilisé (image, texte, etc.) :
  l'utiliser strictement **en l'état**, interdiction de le modifier, de l'étendre (nouveaux
  modèles) ou de le contourner par un service externe non validé.

### II.5 Attentes de comportement de l'agent (à écrire dès le départ, pas après coup)

Ces deux règles ont dû être ajoutées après un incident concret dans ce projet — les inclure
*avant* la première mise en production évite l'incident lui-même :

- **Agir dès qu'un blocage identifié se lève**, sans attendre une relance humaine explicite —
  sauf si l'étape suivante nécessite elle-même un accord explicite (mise en ligne).
- **Vérifier le résultat de toute action asynchrone/automatique** (job système, déploiement,
  envoi de notification) plutôt que de considérer la tâche terminée dès qu'elle est
  déclenchée — contrôler logs et/ou état réel avant de conclure au succès.

---

## III. Les feuilles — ce qui varie par instanciation

| | Blog Photo (ce projet) | Blog littéraire (exemple) | Autre exemple |
|---|---|---|---|
| Unité de contenu | "publication" = 1 à 5 "articles" | "publication" = 1 à N "textes" | — |
| Élément obligatoire par unité | photo générée + prompt, texte, mise en page, mention du modèle | texte + éventuellement image d'illustration, mention des sources/inspirations | — |
| Source de sujets | `themes.md`, thèmes imposés par l'auteur | `themes.md` ou `sujets.md`, mêmes règles (FIFO, jamais choisi par l'agent) | — |
| Outil de génération contraint | ShowMe5WH (image, local, en l'état) | aucun outil de génération contraint — ou un outil d'écriture assistée si l'auteur en impose un | — |
| Titre de la publication | = le thème lui-même | = le thème, ou un titre dérivé si le thème est une contrainte plus abstraite | — |
| Design/mise en page | décidée par l'agent, adaptée au thème | idem | — |

Tout ce qui figure dans ce tableau est à re-décider pour chaque nouvelle instanciation ;
tout ce qui figure dans les sections I, II et IV est à recopier tel quel.

---

## IV. Nœuds et cicatrices — pièges rencontrés, à anticiper dès la conception

Chacun de ces points a coûté un cycle de debugging en production sur ce projet. Les
anticiper au moment de la conception (pas au premier échec) est tout l'intérêt de ce fichier.

1. **Authentification headless ≠ session interactive.**
   Une session OAuth interactive (CLI connecté via navigateur) n'est pas rafraîchie
   automatiquement dans un contexte sans navigateur (launchd/cron). Elle finit par expirer
   silencieusement, avec un échec quasi instantané (0 token consommé) qui ressemble à une
   panne réseau mais n'en est pas une. → Dès la conception, utiliser le mécanisme dédié
   headless de l'outil (ex. `claude setup-token` → jeton longue durée en variable
   d'environnement du job système), jamais la session interactive.

2. **Un "permission mode" partiel n'est pas un accès complet.**
   Un mode qui autorise les *modifications de fichiers* sans supervision (ex.
   `--permission-mode acceptEdits`) ne couvre pas forcément les autres familles d'actions
   (exécution shell, recherche web...). En headless, une demande de confirmation que
   personne ne peut donner bloque le run indéfiniment jusqu'au timeout. → Lister
   explicitement, dès la conception, *toutes* les catégories d'action que le pipeline devra
   effectuer sans supervision, et les autoriser nommément plutôt que découvrir le blocage en
   production.

3. **Toute regex d'extraction sur une sortie générée doit être testée contre une vraie
   sortie, pas contre le format qu'on imagine.**
   Un format "clé: valeur" a souvent un espace après les deux-points dans la pratique même si
   la spec ne le précise pas explicitement — une regex qui suppose zéro espace échoue
   silencieusement même quand tout le reste a parfaitement fonctionné, et produit un message
   d'erreur trompeur ("introuvable") sur un run par ailleurs réussi. → Préférer un format de
   sortie strict et documenté dans le prompt lui-même, et une regex tolérante aux espaces
   dès l'écriture, pas après le premier faux négatif.

4. **Un format encodé (base64, etc.) renvoyé par une API tierce doit être vérifié
   littéralement, pas supposé conforme au standard.**
   Une chaîne base64 peut être préfixée (`data:image/png;base64,...`) sans que ce soit
   documenté — un décodage naïf échoue sur un problème de padding qui n'a rien à voir avec le
   contenu réel. → Inspecter une vraie réponse de l'API avant d'écrire le code de décodage.

5. **"Déployé" et "versionné" sont deux copies distinctes dès qu'un secret existe.**
   Si un fichier de configuration système (plist, crontab...) doit contenir un secret,
   décider *dès le premier jour* laquelle de la copie versionnée (sans secret, pour
   référence/évolution) ou de la copie déployée (avec secret, hors dépôt) fait foi, et
   documenter clairement l'avertissement "ne jamais écraser l'une par l'autre" à l'endroit où
   un futur redéploiement serait tenté — sinon un simple `cp` de bonne foi réintroduit le bug
   d'authentification/permission qui vient d'être corrigé.

6. **Deux jobs indépendants qui touchent le même état partagé (fichier versionné, dépôt
   git) peuvent se percuter.**
   Un job de génération (hebdomadaire) et un job de sondage de validation (toutes les N
   minutes) sont indépendants dans le temps, mais s'ils écrivent tous deux, même rarement,
   dans le même fichier ou dépôt, une fenêtre de collision existe (l'un committe un état
   intermédiaire — ex. des marqueurs de conflit git non résolus — que l'autre pousse en
   ligne avant résolution). → Documenter le risque même si la fenêtre est étroite ; envisager
   qu'un seul des deux jobs ait le droit d'écrire dans l'état partagé si le risque est
   inacceptable.

7. **Un run automatisé qui pousse vers un dépôt distant doit `fetch` avant de `push`,
   ou accepter explicitement qu'un échec de push en headless nécessite une intervention
   manuelle.** Un dépôt distant modifié entre deux runs (par l'auteur directement, ou par un
   autre job) fait échouer un `push` non-fast-forward sans que le pipeline sache résoudre un
   conflit seul — ce n'est pas un bug à corriger dans le script, c'est une limite structurelle
   à anticiper (log clair + notification, pas de tentative de résolution automatique de
   conflit).

8. **Tester chaque brique isolément ne suffit pas — tester le cycle complet réel avant de
   déclarer l'automatisation prête.** Les bugs 1, 2 et 3 ci-dessus ne sont apparus qu'au
   premier vrai run de bout en bout déclenché par le système lui-même (pas par une invocation
   manuelle depuis un terminal déjà authentifié) — un environnement headless diffère d'un
   environnement de développement sur des axes qu'aucun test unitaire ne couvre (auth,
   permissions, variables d'environnement disponibles).

9. **Une tâche headless qui dépasse le timeout par défaut d'une commande shell est basculée
   en arrière-plan sans bloquer l'agent — et rien ne le "réveille" plus tard si le tour de
   conversation se termine avant que la tâche revienne.**
   Toute étape de génération (image, vidéo, tout traitement long) doit recevoir un timeout
   explicite couvrant sa durée réaliste, jusqu'au maximum autorisé par l'outil d'exécution,
   plutôt que le timeout par défaut (souvent 2 min) — sans quoi la commande part en tâche de
   fond dès que la génération est un peu plus longue que d'habitude, et l'agent, livré à
   lui-même, invente à tort un mécanisme de "notification" ou de "reprise ultérieure" qui
   n'existe pas en mode non-interactif : la fin de sa réponse termine le processus pour de
   bon. → Documenter dans le prompt/la procédure le timeout explicite à utiliser pour chaque
   appel long, et interdire toute formulation du type "j'attendrai la suite" en fin de
   réponse tant que le livrable attendu (ici, le marqueur de fin) n'est pas confirmé produit.

---

## V. Squelette de CLAUDE.md à instancier

```markdown
# <Nom du projet> — Contexte projet

## Objectif
<Nature du contenu> avec une publication automatisée <fréquence>.
Mise en ligne uniquement après validation par un tiers.

## Structure d'une publication
<adapter la structure "publication contient N unités" du tronc>

## Structure d'une unité de contenu
<adapter la checklist obligatoire par unité>

## Gestion des sujets/thèmes
- Non choisis par l'agent : imposés, listés dans un fichier source, lu en FIFO et purgé
  au fur et à mesure

## Outils identifiés
<lister les outils de génération/recherche disponibles, avec leurs contraintes d'usage>

## Répartition des décisions
**L'agent décide seul de :** <contenu, forme, stack technique sous contrainte de gratuité...>
**Imposé, hors décision de l'agent :** <le sujet, tiré de la source externe>
**L'agent ne décide jamais seul de :** <mise en ligne finale>

## Garde-fous
### Mise en ligne
<accord explicite obligatoire, preview consultable avant demande d'accord, pas d'accès
identifiants de mise en ligne>
### Outil(s) de génération contraint(s)
<usage en l'état uniquement, pas de nouveaux modèles, pas de service tiers de substitution>
### Périmètre d'action
<pas de modification du CLAUDE.md sans validation, écriture limitée au dossier du projet,
pas de contenu protégé comme matière finale>
### Fiabilité et budget
<nombre max de tentatives, historique/versioning conservé>

## Déclenchement automatique
<mécanisme (launchd/cron), rattrapage si machine éteinte, retry en cas d'échec, canal de
notification, mots-clés de validation, séparation secret déployé / config versionnée>

## Attentes de comportement
- Agir dès qu'un blocage identifié se lève, sans attendre une relance explicite — sauf si
  l'étape suivante nécessite elle-même un accord explicite.
- Vérifier le résultat des actions asynchrones/automatiques avant de conclure au succès.

## Questions ouvertes
<vide au départ — mais prévoir la section dès le premier jet>
```

---

## Comment utiliser ce fichier pour une nouvelle instanciation

1. Copier ce fichier tel quel dans le nouveau projet (hors dépôt Blog Photo — c'est un patron
   générique, pas une doc de ce projet-ci).
2. Remplir la section III ("feuilles") pour le nouveau domaine.
3. Instancier le squelette de la section V en `CLAUDE.md`.
4. Relire la section IV point par point *avant* d'écrire le premier script d'automatisation —
   pas après le premier échec en production.
