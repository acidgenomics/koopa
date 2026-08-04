"""Installer registry unit tests."""

from koopa.install import _app_json_installer
from koopa.installers import has_python_installer
from koopa.io import import_app_json


def test_every_app_has_an_installer() -> None:
    """Every non-tombstoned app.json entry resolves to a Python installer."""
    unroutable = []
    for name, entry in sorted(import_app_json().items()):
        if not isinstance(entry, dict) or entry.get("removed"):
            continue
        if has_python_installer(name):
            continue
        key = _app_json_installer(name)
        if key and has_python_installer(key):
            continue
        unroutable.append(name)
    assert not unroutable, (
        "app.json entries with no Python installer: "
        f"{', '.join(unroutable)}. Add each to PYTHON_INSTALLERS in "
        "lang/python/src/koopa/installers/__init__.py."
    )
