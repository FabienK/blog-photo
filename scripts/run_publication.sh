#!/usr/bin/env bash
# Point d'entrée déclenché par launchd (voir automation/*.plist).
#
# 1. Détermine si une publication est due cette semaine (dimanche courant ou
#    dimanche manqué non traité — rattrapage si le Mac était éteint/endormi).
# 2. Invoque Claude Code en mode non-interactif pour exécuter le pipeline
#    documenté dans automation/PIPELINE.md, avec un nombre limité de
#    tentatives en cas d'échec.
# 3. Notifie l'auteur par SMS (via scripts/notify_author.sh) une fois la
#    preview prête — ou en cas d'échec après épuisement des tentatives.
#
# N'effectue jamais de mise en ligne : le pipeline s'arrête à la preview.

set -uo pipefail

PROJECT_DIR="/Users/fabien_1/Documents/Projets Claude code/Blog photo"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
STATE_DIR="$PROJECT_DIR/automation/state"
LOG_DIR="$PROJECT_DIR/automation/logs"
LAST_RUN_FILE="$STATE_DIR/last_run.txt"
THEMES_FILE="$PROJECT_DIR/themes.md"
CLAUDE_BIN="${CLAUDE_BIN:-/Users/fabien_1/.local/bin/claude}"
MAX_ATTEMPTS=3
RETRY_DELAY_SECONDS=60

mkdir -p "$STATE_DIR" "$LOG_DIR"
RUN_LOG="$LOG_DIR/run_publication.log"

ENV_FILE="$PROJECT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
	set -a
	# shellcheck disable=SC1090
	source "$ENV_FILE"
	set +a
fi

log() {
	printf '%s — %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$1" >>"$RUN_LOG"
}

notify() {
	# Best-effort : une notification qui échoue ne doit pas faire planter le script.
	bash "$SCRIPTS_DIR/notify_author.sh" "$1" "${2:-}" >>"$RUN_LOG" 2>&1 || log "échec de l'envoi SMS (message : $1)"
}

# --- 1. Une publication est-elle due ? ---------------------------------

today_dow=$(date +%u) # 1=lundi ... 7=dimanche
if [[ "$today_dow" == "7" ]]; then
	last_sunday=$(date +%Y-%m-%d)
else
	last_sunday=$(date -v-"${today_dow}"d +%Y-%m-%d)
fi

last_recorded=""
[[ -f "$LAST_RUN_FILE" ]] && last_recorded=$(cat "$LAST_RUN_FILE")

if [[ "$last_recorded" == "$last_sunday" ]]; then
	log "rien à faire : publication déjà réalisée pour la semaine du $last_sunday"
	exit 0
fi

log "publication due pour la semaine du $last_sunday (dernière connue : ${last_recorded:-aucune}) — démarrage"

# --- 2. themes.md a-t-il encore un thème ? ------------------------------

if ! grep -qE '^- ' "$THEMES_FILE"; then
	log "themes.md est vide, aucun thème disponible"
	notify "Prisme : themes.md est vide, impossible de générer une publication. Ajoute des thèmes pour la suite."
	exit 0
fi

# --- 3. Invocation de Claude Code, avec tentatives -----------------------

PROMPT="Exécute la procédure de publication hebdomadaire décrite dans automation/PIPELINE.md (le thème à traiter est la première ligne de themes.md). Termine ta réponse par une ligne exactement au format 'PREVIEW_DIR: publications/<dossier>' comme demandé à l'étape 8 de PIPELINE.md."

attempt=1
success=0
last_out_file=""

while [[ $attempt -le $MAX_ATTEMPTS ]]; do
	log "tentative $attempt/$MAX_ATTEMPTS"
	ts=$(date +%Y%m%dT%H%M%S)
	out_file="$LOG_DIR/claude_${ts}_attempt${attempt}.json"
	err_file="$LOG_DIR/claude_${ts}_attempt${attempt}.err"
	last_out_file="$out_file"

	(
		cd "$PROJECT_DIR" &&
			"$CLAUDE_BIN" -p "$PROMPT" \
				--permission-mode acceptEdits \
				--output-format json \
				>"$out_file" 2>"$err_file"
	)
	exit_code=$?

	if [[ $exit_code -eq 0 ]] && jq -e '.is_error == false' "$out_file" >/dev/null 2>&1; then
		success=1
		break
	fi

	log "tentative $attempt échouée (code sortie $exit_code — voir $err_file)"
	attempt=$((attempt + 1))
	[[ $attempt -le $MAX_ATTEMPTS ]] && sleep "$RETRY_DELAY_SECONDS"
done

if [[ $success -ne 1 ]]; then
	log "échec définitif après $MAX_ATTEMPTS tentatives"
	notify "Prisme : échec de la génération automatique après $MAX_ATTEMPTS tentatives. Vérifie automation/logs/ sur le Mac mini."
	exit 1
fi

# On considère la semaine traitée dès que Claude a terminé sans erreur,
# même si l'extraction du dossier de preview ci-dessous échoue : on ne veut
# pas re-générer une deuxième publication la même semaine en cas de pépin
# purement cosmétique sur la notification.
echo "$last_sunday" >"$LAST_RUN_FILE"

# --- 4. Extraction du dossier de preview + notification SMS -------------

result_text=$(jq -r '.result // ""' "$last_out_file")
preview_dir=$(printf '%s\n' "$result_text" | grep -o 'PREVIEW_DIR:[^[:space:]]*' | tail -1 | sed 's/^PREVIEW_DIR: *//')

if [[ -n "$preview_dir" && -d "$PROJECT_DIR/$preview_dir" ]]; then
	theme_title=$(basename "$preview_dir" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//')
	first_image=$(find "$PROJECT_DIR/$preview_dir" -name "photo.png" | sort | head -1)

	media_url=""
	if [[ -n "${PREVIEW_PUBLIC_BASE_URL:-}" && -n "$first_image" ]]; then
		rel_path="${first_image#"$PROJECT_DIR"/}"
		media_url="${PREVIEW_PUBLIC_BASE_URL%/}/${rel_path}"
	fi

	# SID du dernier SMS entrant AVANT l'envoi de la preview : sert de repère à
	# scripts/check_validation.sh pour détecter une nouvelle réponse, sans
	# dépendre d'un filtre de date côté API (plus robuste).
	baseline_sid=""
	if [[ -n "${TWILIO_ACCOUNT_SID:-}" && -n "${TWILIO_AUTH_TOKEN:-}" && -n "${TWILIO_FROM_NUMBER:-}" && -n "${TWILIO_TO_NUMBER:-}" ]]; then
		baseline_sid=$(curl --silent --show-error \
			-u "${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}" \
			-G "https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json" \
			--data-urlencode "From=${TWILIO_TO_NUMBER}" \
			--data-urlencode "To=${TWILIO_FROM_NUMBER}" \
			--data-urlencode "PageSize=1" 2>>"$RUN_LOG" | jq -r '.messages[0].sid // ""' 2>>"$RUN_LOG")
	fi

	msg="Prisme : la publication \"$theme_title\" est prête ($preview_dir). Réponds OUI / JE VALIDE / OK / GO pour la mettre en ligne."
	notify "$msg" "$media_url"

	sent_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
	jq -n --arg preview_dir "$preview_dir" --arg theme_title "$theme_title" --arg sent_at "$sent_at" --arg baseline_sid "$baseline_sid" \
		'{preview_dir: $preview_dir, theme_title: $theme_title, sent_at: $sent_at, baseline_sid: $baseline_sid}' >"$STATE_DIR/pending_validation.json"
	log "run terminé avec succès — preview : $preview_dir — en attente de validation SMS (voir scripts/check_validation.sh)"
else
	log "run terminé sans erreur mais dossier de preview non détecté dans la réponse"
	notify "Prisme : la génération a réussi mais je n'ai pas retrouvé le dossier de preview automatiquement. Vérifie publications/ sur le Mac mini."
fi

exit 0
