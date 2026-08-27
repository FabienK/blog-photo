#!/usr/bin/env python3
"""Affiche le plus grand UID actuellement présent dans INBOX (0 si vide,
en cas d'erreur, ou si les identifiants Gmail ne sont pas configurés).

Utilisé par run_publication.sh comme repère avant l'envoi de l'email de
preview, pour que check_validation.py puisse ensuite détecter une nouvelle
réponse sans dépendre d'un filtre de date.
"""

import imaplib
import os

from _email_lib import load_env


def main() -> None:
    load_env()
    gmail_address = os.environ.get("GMAIL_ADDRESS")
    app_password = os.environ.get("GMAIL_APP_PASSWORD")
    if not gmail_address or not app_password:
        print(0)
        return

    try:
        imap = imaplib.IMAP4_SSL("imap.gmail.com")
        imap.login(gmail_address, app_password)
        imap.select("INBOX")
        _status, data = imap.uid("search", None, "ALL")
        uids = [int(u) for u in data[0].split()] if data and data[0] else []
        imap.logout()
        print(max(uids) if uids else 0)
    except Exception:  # noqa: BLE001 - repli sûr : 0 déclenche juste un re-sondage plus large
        print(0)


if __name__ == "__main__":
    main()
