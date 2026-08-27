#!/usr/bin/env python3
"""Envoie une notification par email via Gmail SMTP (STARTTLS).

Usage : notify_author.py "<sujet>" "<corps>" [chemin_image]

Variables d'environnement requises (voir .env.example) :
    GMAIL_ADDRESS, GMAIL_APP_PASSWORD, NOTIFY_EMAIL (destinataire, par
    défaut GMAIL_ADDRESS lui-même — usage personnel mono-utilisateur).

Sort avec un code non nul si l'envoi échoue.
"""

import mimetypes
import os
import smtplib
import sys
from email.message import EmailMessage
from pathlib import Path

from _email_lib import load_env


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: notify_author.py <subject> <body> [image_path]", file=sys.stderr)
        return 1

    subject, body = sys.argv[1], sys.argv[2]
    image_path = Path(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else None

    load_env()
    gmail_address = os.environ.get("GMAIL_ADDRESS")
    app_password = os.environ.get("GMAIL_APP_PASSWORD")
    notify_to = os.environ.get("NOTIFY_EMAIL") or gmail_address

    if not gmail_address or not app_password:
        print("notify_author.py: GMAIL_ADDRESS ou GMAIL_APP_PASSWORD manquant (voir .env)", file=sys.stderr)
        return 1

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = f"Prisme <{gmail_address}>"
    msg["To"] = notify_to
    msg.set_content(body)

    if image_path is not None:
        if image_path.is_file():
            mime_type, _ = mimetypes.guess_type(image_path.name)
            maintype, _, subtype = (mime_type or "application/octet-stream").partition("/")
            msg.add_attachment(
                image_path.read_bytes(), maintype=maintype, subtype=subtype or "octet-stream", filename=image_path.name
            )
        else:
            print(f"notify_author.py: image introuvable ({image_path}), envoi sans pièce jointe", file=sys.stderr)

    try:
        with smtplib.SMTP("smtp.gmail.com", 587, timeout=30) as server:
            server.starttls()
            server.login(gmail_address, app_password)
            server.send_message(msg)
    except Exception as exc:  # noqa: BLE001 - on veut juste rapporter l'échec au script appelant
        print(f"notify_author.py: échec de l'envoi ({exc})", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
