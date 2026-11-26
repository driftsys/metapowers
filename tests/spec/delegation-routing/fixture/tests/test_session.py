from src.auth.session import create_session, validate_session


def test_valid_session():
    token = create_session(7)
    assert validate_session(token) == 7


def test_unknown_session():
    assert validate_session("nope") is None
