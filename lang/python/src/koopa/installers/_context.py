"""Install context — holds current app name for mirror URL construction."""

_current_app_name: str = ""


def set_app_name(name: str) -> None:
    global _current_app_name  # noqa: PLW0603
    _current_app_name = name


def get_app_name() -> str:
    return _current_app_name
