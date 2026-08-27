# Automatisation — comment ça marche, et ce qu'il reste à faire

## ⚠️ Bloquant actuel : autorisation macOS requise

Les deux jobs launchd sont chargés (`launchctl load`) mais **échouent
actuellement à chaque déclenchement** avec `Operation not permitted` —
macOS bloque l'accès de `/bin/bash` au dossier `~/Documents` (protection
TCC des dossiers utilisateur) quand le script est lancé par launchd (hors
session Terminal). C'est une autorisation système que je ne peux pas
accorder moi-même (je ne modifie jamais les réglages de sécurité macOS).

**À faire une seule fois, par toi :**
1. Réglages Système → Confidentialité et sécurité → Accès complet au disque
2. Cliquer "+", puis Cmd+Maj+G et taper `/bin/bash`, valider
3. Cocher la case en face de `bash`

Une fois fait, les deux jobs fonctionneront au prochain déclenchement (pas
besoin de recharger). Pour vérifier après coup :
```bash
launchctl list com.fabien.blogphoto.publication
# LastExitStatus doit passer à 0 (au lieu de 32256 actuellement)
```

## Ce qui a été construit

```
scripts/run_publication.sh   → génère la publication (déclenché dimanche 14h)
scripts/notify_author.sh     → envoi SMS/MMS via l'API Twilio (curl, sans dépendance)
scripts/check_validation.sh  → sonde les réponses SMS toutes les 10 min
scripts/publish.sh           → push + mise en ligne réelle, appelé par check_validation.sh
automation/PIPELINE.md       → procédure suivie par Claude à chaque run automatique
automation/*.plist           → 2 jobs launchd (génération hebdo + sondage validation)
automation/state/            → last_run.txt (anti-doublon), pending_validation.json (en attente de réponse)
automation/logs/              → logs de chaque run + sorties JSON de Claude Code
.github/workflows/deploy.yml  → build Astro + déploiement GitHub Pages, déclenché par le push de publish.sh
.env.example                  → gabarit des identifiants Twilio (jamais commité)
```

**Cycle complet, du dimanche à la mise en ligne :**
1. `run_publication.sh` (dimanche 14h, avec rattrapage si le Mac était
   éteint/endormi) invoque Claude Code en headless pour générer la
   publication (jusqu'à 3 tentatives), puis envoie la preview par SMS et
   écrit `pending_validation.json`.
2. `check_validation.sh` (toutes les 10 min, no-op instantané tant que rien
   n'est en attente) sonde les nouveaux SMS entrants. Une réponse
   commençant par **oui / je valide / valide / ok / go / d'accord**
   (insensible à la casse) déclenche `publish.sh`.
3. `publish.sh` pousse la branche `main` vers GitHub → le workflow
   `.github/workflows/deploy.yml` construit le site et le déploie sur
   GitHub Pages → SMS de confirmation avec l'URL en ligne.

Toute autre réponse (ou l'absence de réponse) ne déclenche rien : la
mise en ligne n'a lieu que sur confirmation explicite, conformément à
`CLAUDE.md`.

**Vérifications déjà faites dans cette session** (sur ce Mac mini) :
- `claude -p` fonctionne avec l'authentification par abonnement actuelle,
  y compris dans un environnement dépouillé (PATH minimal, pas de variables
  héritées d'un shell interactif) — proche de ce que verra launchd. Pas
  besoin de clé API séparée ni de compte payant additionnel.
- `--permission-mode acceptEdits` suffit pour que Claude édite des fichiers
  et exécute des commandes Bash (curl, git…) sans blocage sur une invite de
  confirmation — testé avec une écriture de fichier réelle et une commande
  Bash réelle.
- La logique de rattrapage/anti-doublon (`last_run.txt`) a été testée : le
  script détecte correctement qu'une semaine est déjà traitée et ne relance
  rien.
- Les deux jobs launchd sont chargés — mais bloqués par l'autorisation
  macOS ci-dessus, donc le cycle complet n'a pas encore tourné réellement.

**Non testé** : un run complet de bout en bout (génération → SMS → réponse
→ mise en ligne), bloqué par l'autorisation macOS et par l'absence de
compte Twilio.

## Ce qu'il reste à faire (ne peut pas être fait par l'agent)

1. **Accorder l'accès disque complet à `/bin/bash`** — voir encadré en haut
   de ce fichier. Bloquant pour tout le reste.
2. **Créer un compte Twilio** (console.twilio.com), acheter un numéro
   d'envoi, récupérer `Account SID` et `Auth Token`. Coût marginal accepté
   par `CLAUDE.md` malgré la contrainte de gratuité — mais reste une
   démarche avec création de compte et moyen de paiement.
   *Réponse à ta question "un compte pour d'autres projets ou un compte par
   projet" : un seul compte Twilio suffit pour plusieurs projets (tu peux
   y acheter plusieurs numéros, ou réutiliser le même). Pour ce projet,
   un compte + un numéro suffisent largement ; pas besoin de compte dédié
   sauf si tu préfères isoler la facturation.*
3. Copier `.env.example` en `.env` à la racine du projet et renseigner les
   4 variables Twilio. Ce fichier est ignoré par git, il ne sera jamais
   commité ni vu par l'agent.
4. **Décider comment gérer la photo dans le SMS** (texte seul par défaut,
   ou joindre une image — ce qui suppose de l'exposer publiquement, donc
   une forme de mise en ligne à valider explicitement le moment venu).
5. **Activer le déploiement GitHub Pages côté GitHub** — le dépôt a déjà
   une configuration Pages en mode "legacy" (déploiement direct depuis la
   branche, hérité de la création du dépôt), incompatible avec le workflow
   GitHub Actions que j'ai écrit (qui build le site avant de le publier).
   Une tentative de bascule via l'API a été bloquée par mon propre
   classifieur de permissions (changement de réglage de compte). À faire
   par toi, en une fois :
   - Sur github.com : Settings → Pages → Build and deployment → Source →
     **GitHub Actions** (au lieu de "Deploy from a branch")
   - Ou en CLI si tu préfères : `gh api -X PUT repos/FabienK/blog-photo/pages -f build_type=workflow`

## Décisions actées suite à tes réponses

- **Mise en ligne automatique sur réponse affirmative** : construit (voir
  `check_validation.sh` / `publish.sh` ci-dessus). Dès qu'une réponse SMS
  commence par oui/je valide/ok/go/d'accord, la publication correspondante
  part en ligne sans autre confirmation. Si un jour tu réponds autre chose,
  rien ne se passe — la validation reste en attente indéfiniment jusqu'à
  une réponse reconnue.
- **Nom de domaine GitHub Pages** : pas de domaine personnalisé (achat
  payant, hors contrainte de gratuité) — URL par défaut
  `https://fabienk.github.io/blog-photo/`. `astro.config.mjs` et tous les
  liens internes du site sont configurés pour ce chemin.
- **Nouveaux modèles ShowMe5WH** : si tu ajoutes un modèle/checkpoint et le
  déclares dans `backend/presets/presets.json` (voir le dépôt
  Image-generator), l'agent peut l'utiliser normalement — le garde-fou
  CLAUDE.md interdit à l'agent d'installer des modèles lui-même, pas
  d'utiliser ceux que tu as toi-même ajoutés.

## Test manuel recommandé (une fois les deux bloquants levés)

Pour tester le pipeline complet sans attendre dimanche :
```bash
rm automation/state/last_run.txt   # force le script à considérer un run comme dû
bash scripts/run_publication.sh
```
⚠️ Cela consommera réellement le prochain thème de `themes.md`, générera
une vraie publication (photos comprises), et — si tu réponds
oui/ok/go au SMS reçu — la mettra réellement en ligne. À faire en
connaissance de cause, pas comme un test anodin.
