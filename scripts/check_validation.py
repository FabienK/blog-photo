#!/usr/bin/env python3
"""Sondage périodique (voir automation/com.fabien.blogphoto.checkvalidation.plist)
des réponses email de l'auteur, tant qu'une publication attend sa validation.
Ne fait aucune connexion IMAP si aucune validation n'est en attente (coût nul).

Détecte une nouvelle réponse en comparant le plus récent UID de INBOX au
"baseline_uid" capturé juste avant l'envoi de l'email de preview (voir
run_publication.sh / gmail_latest_uid.py).

Une réponse affirmative ("oui", "je valide", "valide", "ok", "go",
"d'accord" — au tout début du message, insensible à la casse) déclenche
scripts/publish.sh, qui pousse réellement la publication en ligne. C'est
la seule façon dont ce pipeline met quelque chose en ligne — jamais
automatiquement, toujours sur confirmation explicite de l'auteur (voir
CLAUDE.md).
"""

import datetime
import email
import imaplib
import json
import os
import re
import subprocess
import sys

from _email_lib import PROJECT_DIR, get_text_body, load_env

STATE_DIR = PROJECT_DIR / "automation" / "state"
LOG_DIR = PROJECT_DIR / "automation" / "logs"
PENDING_FILE = STATE_DIR / "pending_validation.json"
RUN_LOG = LOG_DIR / "run_publication.log"

AFFIRMATIVE_RE = re.compile(r"^\s*(oui|je valide|valide|ok(ay)?|go|d.accord)\b", re.IGNORECASE)


def log(message: str) -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    with RUN_LOG.open("a", encoding="utf-8") as f:
        f.write(f"{datetime.datetime.now().isoformat()} — [validation] {message}\n")


def main() -> int:
    if not PENDING_FILE.exists():
        return 0  # rien en attente, aucun appel réseau

    load_env()
    gmail_address = os.environ.get("GMAIL_ADDRESS")
    app_password = os.environ.get("GMAIL_APP_PASSWORD")
    if not gmail_address or not app_password:
        log("GMAIL_ADDRESS ou GMAIL_APP_PASSWORD manquant, sondage impossible")
        return 1

    pending = json.loads(PENDING_FILE.read_text(encoding="utf-8"))
    preview_dir = pending["preview_dir"]
    theme_title = pending["theme_title"]
    baseline_uid = int(pending.get("baseline_uid", 0))

    try:
        imap = imaplib.IMAP4_SSL("imap.gmail.com")
        imap.login(gmail_address, app_password)
        imap.select("INBOX")
        _status, data = imap.uid("search", None, "ALL")
        uids = [int(u) for u in data[0].split()] if data and data[0] else []
        new_uids = [u for u in uids if u > baseline_uid]
        if not new_uids:
            imap.logout()
            return 0
        latest_uid = max(new_uids)
        _status, msg_data = imap.uid("fetch", str(latest_uid), "(RFC822)")
        raw = msg_data[0][1]
        imap.logout()
    except Exception as exc:  # noqa: BLE001
        log(f"échec de la connexion IMAP : {exc}")
        return 1

    msg = email.message_from_bytes(raw)
    body = get_text_body(msg).strip()

    if AFFIRMATIVE_RE.match(body):
        preview = body[:80].replace("\n", " ")
        log(f'réponse affirmative reçue ("{preview}") — déclenchement de la publication')
        result = subprocess.run(["bash", str(PROJECT_DIR / "scripts" / "publish.sh"), preview_dir, theme_title])
        if result.returncode == 0:
            PENDING_FILE.unlink(missing_ok=True)
        else:
            log("publish.sh a échoué, validation laissée en attente pour un nouveau sondage")
    else:
        preview = body[:80].replace("\n", " ")
        log(f'réponse reçue non reconnue comme affirmative ("{preview}") — aucune action')

    return 0


if __name__ == "__main__":
    sys.exit(main())
