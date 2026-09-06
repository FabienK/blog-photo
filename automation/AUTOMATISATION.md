# Automatisation — comment ça marche, et ce qu'il reste à faire

Twilio a été abandonné le 2026-08-27 : la procédure d'inscription/conformité
pour obtenir un numéro capable d'envoyer des SMS s'est révélée bloquante
(formulaires qui ne progressent pas, écrans blancs, numéro acheté mais
finalement incapable d'envoyer). Remplacé par une notification **email**
(Gmail), plus simple à mettre en place et gratuite, avec un avantage
supplémentaire : la photo peut être jointe directement, sans contournement
nécessaire (contrairement au MMS qui exige une URL publique).

## Ce qui a été construit

```
scripts/run_publication.sh   → génère la publication (déclenché dimanche 14h)
scripts/notify_author.py     → envoi d'email via Gmail SMTP (photo en pièce jointe)
scripts/check_validation.py  → sonde les réponses par email toutes les 10 min (IMAP)
scripts/gmail_latest_uid.py  → repère le dernier email reçu avant l'envoi de la preview
scripts/publish.sh           → push + mise en ligne réelle, appelé par check_validation.py
scripts/_email_lib.py        → utilitaires partagés (chargement .env, extraction du texte)
automation/PIPELINE.md       → procédure suivie par Claude à chaque run automatique
automation/*.plist           → 2 jobs launchd (génération hebdo + sondage validation)
automation/state/            → last_run.txt (anti-doublon), pending_validation.json (en attente de réponse)
automation/logs/              → logs de chaque run + sorties JSON de Claude Code
.github/workflows/deploy.yml  → build Astro + déploiement GitHub Pages, déclenché par le push de publish.sh
.env.example                  → gabarit des identifiants Gmail (jamais commité)
```

**Cycle complet, du dimanche à la mise en ligne :**
1. `run_publication.sh` (dimanche 14h, avec rattrapage si le Mac était
   éteint/endormi) invoque Claude Code en headless pour générer la
   publication (jusqu'à 3 tentatives), puis envoie la preview par email
   (photo du premier article en pièce jointe) et écrit
   `pending_validation.json`.
2. `check_validation.py` (toutes les 10 min, no-op instantané tant que rien
   n'est en attente — aucune connexion IMAP sinon) sonde la boîte Gmail.
   Une réponse commençant par **oui / je valide / valide / ok / go /
   d'accord** (insensible à la casse) déclenche `publish.sh`.
3. `publish.sh` pousse la branche `main` vers GitHub → le workflow
   `.github/workflows/deploy.yml` construit le site et le déploie sur
   GitHub Pages → email de confirmation avec l'URL en ligne.

Toute autre réponse (ou l'absence de réponse) ne déclenche rien : la
mise en ligne n'a lieu que sur confirmation explicite, conformément à
`CLAUDE.md`.

**Vérifications faites (mises à jour le 2026-09-06) :**
- Logique de rattrapage/anti-doublon (`last_run.txt`) testée.
- Les deux jobs launchd sont chargés et fonctionnels (`LastExitStatus = 0`)
  — l'autorisation macOS "Accès complet au disque" pour `/bin/bash` a été
  accordée par l'auteur et vérifiée.
- GitHub Pages configuré en mode "GitHub Actions" (`build_type: workflow`),
  compatible avec le workflow de déploiement.
- **Cycle email complet testé et fonctionnel** (envoi de preview → réponse
  → mise en ligne), confirmé sur les publications "Élégance" et "Idée".
- **Authentification et permissions du run headless, corrigées le
  2026-09-06** — voir `etat.md` (section "Journal d'avancement", entrée du
  2026-09-06) pour le détail des trois bugs trouvés et corrigés :
  jeton OAuth longue durée requis (`claude -p` avec la session interactive
  seule échoue en headless au bout de quelques heures), `--permission-mode
  acceptEdits` seul insuffisant (`--allowedTools "Bash" "WebSearch"`
  ajouté), et une regex d'extraction de `PREVIEW_DIR:` corrigée dans
  `scripts/run_publication.sh`.

**⚠️ Point d'attention — plist déployé vs plist versionné.** Le job
réellement chargé par launchd est
`~/Library/LaunchAgents/com.fabien.blogphoto.publication.plist`, **hors du
dépôt Git** — pas le fichier versionné dans `automation/`. Depuis le
2026-09-06, la copie déployée porte une clé `CLAUDE_CODE_OAUTH_TOKEN`
(jeton longue durée généré par `claude setup-token`) dans
`EnvironmentVariables`, absente de la copie versionnée (qui reste
volontairement sans secret, pour ne jamais faire transiter le jeton par
Git). **Ne jamais recopier `automation/com.fabien.blogphoto.publication.plist`
par-dessus la copie déployée** — ça effacerait le jeton et referait planter
le pipeline automatique avec la même erreur d'authentification. Si le
jeton doit être régénéré (expire ~1 an après génération, soit vers
septembre 2027), éditer directement le fichier dans
`~/Library/LaunchAgents/`.

## Décisions actées

- **Notification par email**, pas SMS/Twilio (voir CLAUDE.md, mis à jour
  le 2026-08-27 avec l'accord de l'auteur).
- **Mise en ligne automatique sur réponse affirmative** : dès qu'une
  réponse email commence par oui/je valide/ok/go/d'accord, la publication
  correspondante part en ligne sans autre confirmation. Toute autre
  réponse (ou l'absence de réponse) laisse la validation en attente
  indéfiniment.
- **Nom de domaine GitHub Pages** : pas de domaine personnalisé (achat
  payant, hors contrainte de gratuité) — URL par défaut
  `https://fabienk.github.io/blog-photo/`.
- **Nouveaux modèles ShowMe5WH** : si l'auteur ajoute un modèle/checkpoint
  et le déclare dans `backend/presets/presets.json`, l'agent peut
  l'utiliser normalement — le garde-fou CLAUDE.md interdit à l'agent
  d'installer des modèles lui-même, pas d'utiliser ceux ajoutés par
  l'auteur.

## Test manuel recommandé (une fois le mot de passe d'application renseigné)

Pour tester le pipeline complet sans attendre dimanche :
```bash
rm automation/state/last_run.txt   # force le script à considérer un run comme dû
bash scripts/run_publication.sh
```
⚠️ Cela consommera réellement le prochain thème de `themes.md`, générera
une vraie publication (photos comprises), et — si tu réponds
oui/ok/go à l'email reçu — la mettra réellement en ligne. À faire en
connaissance de cause, pas comme un test anodin.
