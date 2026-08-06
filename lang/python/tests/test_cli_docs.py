"""Completeness tests for koopa.cli_docs description tables.

Cross-checks every description table against its authoritative source (the
dispatch tables in generate_completion.py, cli_bin.py, cli_system.py, and
cli_app.py) so a newly added command fails CI instead of silently rendering
with an empty description in the man page or the Sphinx CLI reference.
"""

from koopa.cli_app import _APP_TREE
from koopa.cli_bin import _HANDLERS as _RUN_HANDLERS
from koopa.cli_docs import (
    ADMIN_DESCRIPTIONS,
    APP_DESCRIPTIONS,
    APP_NAMESPACE_DESCRIPTIONS,
    DEVELOP_DESCRIPTIONS,
    RUN_DESCRIPTIONS,
    SYSTEM_DESCRIPTIONS,
)
from koopa.cli_system import _ADMIN_HANDLERS
from koopa.generate_completion import _ADMIN_COMMANDS, _SYSTEM_COMMANDS, _load_develop_commands


def _flatten_app_tree(tree: dict) -> set[str]:
    """Return the set of handler-key leaves in the app dispatch tree."""
    leaves: set[str] = set()
    for value in tree.values():
        if isinstance(value, dict):
            leaves |= _flatten_app_tree(value)
        else:
            leaves.add(value)
    return leaves


def test_system_descriptions_cover_all_commands() -> None:
    """Test every koopa system command has a description."""
    names = {name for name, _ in _SYSTEM_COMMANDS}
    missing = names - set(SYSTEM_DESCRIPTIONS)
    assert not missing, f"Missing system descriptions: {sorted(missing)}"


def test_admin_descriptions_cover_all_commands() -> None:
    """Test every koopa admin command has a description."""
    names = {name for name, _ in _ADMIN_COMMANDS}
    missing = names - set(ADMIN_DESCRIPTIONS)
    assert not missing, f"Missing admin descriptions: {sorted(missing)}"
    assert names == set(_ADMIN_HANDLERS), "admin command table and handler registry disagree"


def test_develop_descriptions_cover_all_commands() -> None:
    """Test every koopa develop command has a description."""
    names = set(_load_develop_commands())
    missing = names - set(DEVELOP_DESCRIPTIONS)
    assert not missing, f"Missing develop descriptions: {sorted(missing)}"


def test_run_descriptions_cover_all_commands() -> None:
    """Test every koopa run command has a description."""
    names = set(_RUN_HANDLERS)
    missing = names - set(RUN_DESCRIPTIONS)
    assert not missing, f"Missing run descriptions: {sorted(missing)}"


def test_app_descriptions_cover_all_leaves() -> None:
    """Test every koopa app leaf command has a description."""
    leaves = _flatten_app_tree(_APP_TREE)
    missing = leaves - set(APP_DESCRIPTIONS)
    assert not missing, f"Missing app descriptions: {sorted(missing)}"


def test_app_namespace_descriptions_cover_all_namespaces() -> None:
    """Test every koopa app namespace has a description."""
    namespaces = set(_APP_TREE)
    missing = namespaces - set(APP_NAMESPACE_DESCRIPTIONS)
    assert not missing, f"Missing app namespace descriptions: {sorted(missing)}"
