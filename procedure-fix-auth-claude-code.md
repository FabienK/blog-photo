# Procédure — Corriger l'authentification Claude Code dans l'automatisation Blog Photo

## Contexte

Le pipeline (`run_publication.sh`, déclenché par `com.fabien.blogphoto.publication.plist` via launchd) invoque le CLI Claude Code en mode non-interactif (`claude -p ...`). Cette invocation utilise la session OAuth interactive classique, qui expire après ~8h et n'est jamais rafraîchie automatiquement (le `refreshToken` existe dans `~/.claude/.credentials.json` mais n'est pas utilisé par le CLI).

**Conséquence observée** : le pipeline fonctionne juste après une connexion manuelle, puis échoue silencieusement (code sortie 1, `.err` vides) une semaine plus tard quand launchd le relance sans humain devant la machine. Confirmé les 30 août et 6 septembre 2026 par le message `Failed to authenticate: OAuth session expired and could not be refreshed` dans les fichiers `automation/logs/claude_*_attemptN.json`.

## Correctif retenu

Remplacer la session OAuth interactive par un jeton longue durée dédié à l'automatisation (`claude setup-token`), qui reste rattaché à l'abonnement Pro — pas de bascule vers une facturation API séparée.

## Étapes

### 1. Générer le jeton

Sur le Mac mini, dans un terminal :

```bash
claude setup-token
```

Un flux OAuth s'ouvre dans le navigateur. Une fois complété, le terminal affiche un jeton au format `sk-ant-oat01-...`. Copier la valeur complète.

### 2. Ajouter le jeton au plist

Éditer `~/Library/LaunchAgents/com.fabien.blogphoto.publication.plist` — **uniquement cette copie déployée, hors du dépôt Git**, pas `automation/com.fabien.blogphoto.publication.plist` versionné dans le projet, qui doit rester sans secret. Les deux fichiers sont aujourd'hui volontairement différents ; ne jamais recopier l'un sur l'autre. Dans la section `EnvironmentVariables` déjà existante (celle qui contient `PATH`) :

```xml
<key>EnvironmentVariables</key>
<dict>
<key>PATH</key>
<string>/Users/fabien_1/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
<key>CLAUDE_CODE_OAUTH_TOKEN</key>
<string>sk-ant-oat01-xxxxxxxxxxxxx</string>
</dict>
```

### 3. Recharger le job

```bash
launchctl unload ~/Library/LaunchAgents/com.fabien.blogphoto.publication.plist
launchctl load ~/Library/LaunchAgents/com.fabien.blogphoto.publication.plist
```

### 4. Tester sans attendre dimanche

```bash
launchctl start com.fabien.blogphoto.publication
```

Puis vérifier :

```bash
tail -50 "/Users/fabien_1/Documents/Projets Claude code/Blog photo/automation/logs/run_publication.log"
```

Un run réussi ne doit plus produire de message d'échec d'authentification dans le `.json` de la tentative.

## Limites connues, à surveiller

- **Durée de vie du jeton : 1 an, confirmé par la documentation officielle** (code.claude.com/docs/en/iam). Généré le 2026-09-06, à régénérer avant ~septembre 2027 (pas d'alerte automatique — vérifier `run_publication.log` de temps en temps, notamment si l'erreur d'authentification d'origine revenait).
- **Un login interactif futur sur cette machine n'affecte pas l'automatisation.** Si une connexion `claude login` est relancée à la main sur ce Mac mini pour un autre usage, le pipeline continuera d'utiliser le jeton fixé dans le plist, sans en tenir compte — comportement voulu ici, mais à ne pas confondre avec un bug si l'automatisation semble "ignorer" une reconnexion.
- **Chemin de code `--bg` du CLI.** Une inspection du binaire installé montre que le mode démon en arrière-plan (`--bg`, non utilisé par ce pipeline) supprime `CLAUDE_CODE_OAUTH_TOKEN` de son environnement sur macOS. Notre invocation utilise `-p` simple, a priori non concernée — à vérifier en premier si l'erreur d'authentification revenait malgré le jeton en place.

## Statut

Correctif appliqué et vérifié le 2026-09-06 : run automatique réussi de bout en bout (authentification, génération complète, preview, validation par email, mise en ligne) pour la publication "Idée". Deux autres bugs, distincts de l'authentification, ont été découverts et corrigés au passage (permissions `Bash`/`WebSearch` insuffisantes en headless, regex d'extraction de `PREVIEW_DIR:` incompatible avec le format demandé) — voir `etat.md` pour le détail complet.
