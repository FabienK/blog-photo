#!/usr/bin/env bash
# Envoie une notification SMS (et MMS si une image publique est disponible)
# à l'auteur via l'API REST Twilio. Ne dépend que de curl.
#
# Usage :
#   notify_author.sh "texte du message" [url_image_publique]
#
# Variables d'environnement requises (voir .env.example) :
#   TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER, TWILIO_TO_NUMBER
#
# Sort avec un code non nul si l'envoi échoue (permet au script appelant de
# le consigner sans bloquer tout le pipeline pour un simple souci réseau).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
if [[ -f "$ENV_FILE" ]]; then
	set -a
	# shellcheck disable=SC1090
	source "$ENV_FILE"
	set +a
fi

MESSAGE="${1:-}"
MEDIA_URL="${2:-}"

if [[ -z "$MESSAGE" ]]; then
	echo "notify_author.sh: message manquant" >&2
	exit 1
fi

for var in TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_FROM_NUMBER TWILIO_TO_NUMBER; do
	if [[ -z "${!var:-}" ]]; then
		echo "notify_author.sh: variable d'environnement $var manquante (voir .env)" >&2
		exit 1
	fi
done

ARGS=(
	--silent --show-error --fail
	-X POST "https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json"
	-u "${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}"
	--data-urlencode "From=${TWILIO_FROM_NUMBER}"
	--data-urlencode "To=${TWILIO_TO_NUMBER}"
	--data-urlencode "Body=${MESSAGE}"
)

if [[ -n "$MEDIA_URL" ]]; then
	ARGS+=(--data-urlencode "MediaUrl=${MEDIA_URL}")
fi

curl "${ARGS[@]}"
echo
