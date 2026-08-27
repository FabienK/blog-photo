"""Utilitaires partagés pour l'automatisation par email (Gmail SMTP/IMAP).

Non exécutable directement — importé par notify_author.py,
check_validation.py et gmail_latest_uid.py.
"""

import os
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent


def load_env() -> None:
    """Charge .env dans os.environ (ne remplace jamais une variable déjà définie)."""
    env_path = PROJECT_DIR / ".env"
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        os.environ.setdefault(key.strip(), value.strip())


def get_text_body(msg) -> str:
    """Extrait le texte brut d'un email.message.Message, multipart ou non."""
    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == "text/plain" and not part.get("Content-Disposition"):
                charset = part.get_content_charset() or "utf-8"
                payload = part.get_payload(decode=True)
                return payload.decode(charset, errors="replace") if payload else ""
        return ""
    charset = msg.get_content_charset() or "utf-8"
    payload = msg.get_payload(decode=True)
    return payload.decode(charset, errors="replace") if payload else ""
