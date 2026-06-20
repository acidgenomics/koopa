"""Install context — holds current app name and version for URL resolution."""

_current_app_name: str = ""
_current_app_version: str = ""


def set_app_name(name: str) -> None:
    global _current_app_name  # noqa: PLW0603
    _current_app_name = name


def get_app_name() -> str:
    return _current_app_name


def set_app_version(version: str) -> None:
    global _current_app_version  # noqa: PLW0603
    _current_app_version = version


def get_app_version() -> str:
    return _current_app_version
