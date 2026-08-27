#!/usr/bin/env bash
# Met réellement la publication en ligne : pousse la branche main vers
# GitHub (ce qui déclenche le déploiement GitHub Pages via
# .github/workflows/deploy.yml), consigne l'événement dans etat.md, et
# confirme par SMS. N'est appelé que par scripts/check_validation.sh, lui
#-même déclenché uniquement après une réponse SMS affirmative de l'auteur.
#
# Usage : publish.sh <preview_dir relatif> <titre_theme>

set -euo pipefail

PROJECT_DIR="/Users/fabien_1/Documents/Projets Claude code/Blog photo"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOG_DIR="$PROJECT_DIR/automation/logs"
mkdir -p "$LOG_DIR"
RUN_LOG="$LOG_DIR/run_publication.log"

log() { printf '%s — [publish] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$1" >>"$RUN_LOG"; }

PREVIEW_DIR="${1:?usage: publish.sh <preview_dir> <theme_title>}"
THEME_TITLE="${2:?usage: publish.sh <preview_dir> <theme_title>}"
SLUG=$(basename "$PREVIEW_DIR" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//')
SITE_URL="https://fabienk.github.io/blog-photo/${SLUG}/"

cd "$PROJECT_DIR"

# S'assure qu'il n'y a pas de modifications non commitées avant de pousser
# (le pipeline commite normalement déjà localement — voir PIPELINE.md étape 7).
if ! git diff --quiet || ! git diff --cached --quiet; then
	git add -A
	git commit -q -m "Publication automatique : ${THEME_TITLE}"
	log "commit local créé avant push (des changements n'avaient pas été commités par le pipeline)"
fi

log "push vers origin/main pour la publication \"$THEME_TITLE\""
if ! git push origin main >>"$RUN_LOG" 2>&1; then
	log "échec du push — mise en ligne annulée"
	bash "$SCRIPTS_DIR/notify_author.sh" "Prisme : la validation a été reçue mais le push vers GitHub a échoué. Vérifie automation/logs/ sur le Mac mini." || true
	exit 1
fi

# Ajout d'une ligne au journal d'etat.md (insertion juste après le titre de
# la section, en tête de journal — modification additive uniquement).
python3 - "$PROJECT_DIR/etat.md" "$THEME_TITLE" "$SITE_URL" <<'PYEOF'
import sys, datetime
path, theme, url = sys.argv[1], sys.argv[2], sys.argv[3]
marker = "## 6. Journal d'avancement\n"
today = datetime.date.today().isoformat()
entry = f"- **{today}** — Mise en ligne automatique de la publication \"{theme}\" suite à validation SMS : {url}\n"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()
idx = content.find(marker)
if idx == -1:
    with open(path, "a", encoding="utf-8") as f:
        f.write("\n" + marker + entry)
else:
    insert_at = idx + len(marker)
    content = content[:insert_at] + entry + content[insert_at:]
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
PYEOF

git add etat.md
git commit -q -m "etat.md : mise en ligne de \"${THEME_TITLE}\""
git push origin main >>"$RUN_LOG" 2>&1 || log "avertissement : push du journal etat.md a échoué (mise en ligne déjà faite)"

bash "$SCRIPTS_DIR/notify_author.sh" "Prisme : \"$THEME_TITLE\" est en ligne → $SITE_URL" || log "échec de l'envoi du SMS de confirmation"

log "publication \"$THEME_TITLE\" mise en ligne avec succès : $SITE_URL"
