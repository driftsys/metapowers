"""Session handling."""
import secrets
import time

SESSIONS = {}


def create_session(user_id):
    token = secrets.token_hex(16)
    SESSIONS[token] = {"user_id": user_id, "created": time.time()}
    return token


def validate_session(token):
    session = SESSIONS.get(token)
    if session is None:
        return None
    return session["user_id"]
