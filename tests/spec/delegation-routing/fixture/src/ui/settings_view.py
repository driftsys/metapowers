"""Settings screen."""


def render_settings(user):
    theme = user.get("theme", "light")
    return f"<h1>Settings for {user['name']}</h1><p>Theme: {theme}</p>"
