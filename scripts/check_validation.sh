#!/usr/bin/env bash
# Sondage périodique (voir automation/com.fabien.blogphoto.checkvalidation.plist)
# des réponses SMS de l'auteur, tant qu'une publication attend sa validation.
# Ne fait aucun appel réseau si aucune validation n'est en attente (coût nul).
#
# Détecte une nouvelle réponse en comparant le SID du dernier SMS entrant au
# "baseline_sid" capturé juste avant l'envoi de la preview (voir
# run_publication.sh) — plus robuste qu'un filtre de date côté API Twilio.
#
# Une réponse affirmative ("oui", "je valide", "valide", "ok", "go", "d'accord"
# — au tout début du message, insensible à la casse) déclenche scripts/publish.sh,
# qui pousse réellement la publication en ligne. C'est la seule façon dont ce
# pipeline met quelque chose en ligne — jamais automatiquement, toujours sur
# confirmation explicite de l'auteur par SMS (voir CLAUDE.md).

set -uo pipefail

PROJECT_DIR="/Users/fabien_1/Documents/Projets Claude code/Blog photo"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
STATE_DIR="$PROJECT_DIR/automation/state"
LOG_DIR="$PROJECT_DIR/automation/logs"
PENDING_FILE="$STATE_DIR/pending_validation.json"
RUN_LOG="$LOG_DIR/run_publication.log"

log() { printf '%s — [validation] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$1" >>"$RUN_LOG"; }

# Rien en attente : sortie immédiate, aucun appel Twilio.
[[ -f "$PENDING_FILE" ]] || exit 0

ENV_FILE="$PROJECT_DIR/.env"
[[ -f "$ENV_FILE" ]] && {
	set -a
	# shellcheck disable=SC1090
	source "$ENV_FILE"
	set +a
}

for var in TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_FROM_NUMBER TWILIO_TO_NUMBER; do
	if [[ -z "${!var:-}" ]]; then
		log "variable $var manquante, sondage impossible"
		exit 1
	fi
done

preview_dir=$(jq -r '.preview_dir' "$PENDING_FILE")
theme_title=$(jq -r '.theme_title' "$PENDING_FILE")
baseline_sid=$(jq -r '.baseline_sid // ""' "$PENDING_FILE")

response=$(curl --silent --show-error --fail \
	-u "${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}" \
	-G "https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json" \
	--data-urlencode "From=${TWILIO_TO_NUMBER}" \
	--data-urlencode "To=${TWILIO_FROM_NUMBER}" \
	--data-urlencode "PageSize=1") || {
	log "échec de l'appel à l'API Twilio (réseau ou identifiants)"
	exit 1
}

latest_sid=$(echo "$response" | jq -r '.messages[0].sid // ""')
latest_body=$(echo "$response" | jq -r '.messages[0].body // ""')

if [[ -z "$latest_sid" || "$latest_sid" == "$baseline_sid" ]]; then
	exit 0 # pas encore de nouvelle réponse depuis l'envoi de la preview
fi

if echo "$latest_body" | grep -qiE "^[[:space:]]*(oui|je valide|valide|ok(ay)?|go|d.accord)\b"; then
	log "réponse affirmative reçue (\"$latest_body\") — déclenchement de la publication"
	if bash "$SCRIPTS_DIR/publish.sh" "$preview_dir" "$theme_title"; then
		rm -f "$PENDING_FILE"
	else
		log "publish.sh a échoué, validation laissée en attente pour un nouveau sondage"
	fi
else
	log "réponse reçue non reconnue comme affirmative (\"$latest_body\") — aucune action, en attente d'une confirmation"
fi
