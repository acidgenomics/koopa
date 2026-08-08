"""Tests for koopa.configurers.color_mode helpers."""

from pathlib import Path

import pytest
from koopa.configurers.color_mode import (
    _chezmoi_source_to_target,
    _discover_color_mode_targets,
)

# ---------------------------------------------------------------------------
# _chezmoi_source_to_target
# ---------------------------------------------------------------------------


def test_chezmoi_source_to_target_strips_dot_prefix_and_tmpl_suffix() -> None:
    """'dot_' becomes '.' and the '.tmpl' suffix is stripped."""
    target = _chezmoi_source_to_target("/src", "/src/dot_bashrc.tmpl")
    assert target == str(Path.home() / ".bashrc")


def test_chezmoi_source_to_target_strips_attribute_prefixes() -> None:
    """Known chezmoi attribute prefixes (e.g. 'private_') are stripped."""
    target = _chezmoi_source_to_target("/src", "/src/private_dot_npmrc.tmpl")
    assert target == str(Path.home() / ".npmrc")


def test_chezmoi_source_to_target_nested_directories() -> None:
    """Nested source directories map to nested target paths component-wise."""
    target = _chezmoi_source_to_target("/src", "/src/dot_config/bat/config.tmpl")
    assert target == str(Path.home() / ".config" / "bat" / "config")


# ---------------------------------------------------------------------------
# _discover_color_mode_targets
# ---------------------------------------------------------------------------


def _write_tmpl(root: Path, rel: str, contents: bytes) -> None:
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(contents)


def test_discover_color_mode_targets_keeps_managed_target(tmp_path: Path) -> None:
    """A discovered target present in the managed set is kept."""
    chezmoi_prefix = tmp_path / "chezmoi"
    _write_tmpl(chezmoi_prefix, "dot_config/bat/config.tmpl", b"KOOPA_COLOR_MODE")
    target = str(Path.home() / ".config" / "bat" / "config")
    target_rel = ".config/bat/config"

    targets = _discover_color_mode_targets(str(chezmoi_prefix), {target_rel})
    assert targets == [target]


def test_discover_color_mode_targets_drops_unmanaged_target(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A discovered target absent from the managed set is dropped and warned about.

    This is the exact failure mode that wedged color-mode sync: a template that
    branches on KOOPA_COLOR_MODE whose target is .chezmoiignore'd (e.g. because a
    work-tree marker is present) but still exists on disk under another tree's
    management.  Passing it to 'chezmoi apply' as a target arg aborts the entire
    call, so it must never reach the apply target list.
    """
    chezmoi_prefix = tmp_path / "chezmoi"
    _write_tmpl(chezmoi_prefix, "dot_claude/settings.json.tmpl", b"KOOPA_COLOR_MODE")

    targets = _discover_color_mode_targets(str(chezmoi_prefix), managed=set())
    assert targets == []
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Warning" in combined
    assert "settings.json" in combined


def test_discover_color_mode_targets_mixed_managed_and_unmanaged(tmp_path: Path) -> None:
    """Only the unmanaged subset is dropped; managed targets are unaffected."""
    chezmoi_prefix = tmp_path / "chezmoi"
    _write_tmpl(chezmoi_prefix, "dot_config/bat/config.tmpl", b"KOOPA_COLOR_MODE")
    _write_tmpl(chezmoi_prefix, "dot_claude/settings.json.tmpl", b"KOOPA_COLOR_MODE")
    kept_target = str(Path.home() / ".config" / "bat" / "config")

    targets = _discover_color_mode_targets(str(chezmoi_prefix), {".config/bat/config"})
    assert targets == [kept_target]


def test_discover_color_mode_targets_ignores_templates_without_needle(tmp_path: Path) -> None:
    """Templates that don't reference KOOPA_COLOR_MODE are never candidates."""
    chezmoi_prefix = tmp_path / "chezmoi"
    _write_tmpl(chezmoi_prefix, "dot_gitconfig.tmpl", b"no color mode reference here")

    targets = _discover_color_mode_targets(str(chezmoi_prefix), managed={".gitconfig"})
    assert targets == []


def test_discover_color_mode_targets_no_managed_no_apply_everything(tmp_path: Path) -> None:
    """An empty managed set (probe failure) never falls back to 'apply everything'.

    _chezmoi_managed() degrades to an empty set on subprocess failure by design.
    If discovery treated that as 'nothing is managed, so include nothing gets
    inverted to include everything' the fix would silently reintroduce the
    original bug under exactly the failure condition it exists to guard against.
    """
    chezmoi_prefix = tmp_path / "chezmoi"
    _write_tmpl(chezmoi_prefix, "dot_config/starship.toml.tmpl", b"KOOPA_COLOR_MODE")

    targets = _discover_color_mode_targets(str(chezmoi_prefix), managed=set())
    assert targets == []
