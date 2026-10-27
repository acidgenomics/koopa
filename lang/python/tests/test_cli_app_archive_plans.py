"""Tests for koopa app claude/copilot archive-plans subcommands."""

import os
import time
from pathlib import Path

import pytest
from koopa.cli_app import _APP_TREE, _PYTHON_HANDLERS

_TOOLS = ["claude", "copilot"]
_DAY = 86400


def _write_plan(plans_dir: Path, name: str, age_days: int) -> Path:
    """Write a plan file whose mtime is ``age_days`` days old."""
    path = plans_dir / name
    path.write_text("# Plan\n")
    mtime = time.time() - age_days * _DAY
    os.utime(path, (mtime, mtime))
    return path


@pytest.mark.parametrize("tool", _TOOLS)
def test_archive_plans_registered(tool: str) -> None:
    """The command is in both the app tree and the handler table."""
    assert _APP_TREE[tool]["archive-plans"] == f"{tool}-archive-plans"
    assert callable(_PYTHON_HANDLERS[f"{tool}-archive-plans"])


@pytest.mark.parametrize("tool", _TOOLS)
def test_archive_plans_moves_old_files(
    tool: str, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """An old plan moves to archive/YYYY/MM/DD; a new plan stays."""
    plans_dir = tmp_path / f".{tool}" / "plans"
    plans_dir.mkdir(parents=True)
    old = _write_plan(plans_dir, "old-plan.md", age_days=30)
    new = _write_plan(plans_dir, "new-plan.md", age_days=1)
    monkeypatch.chdir(tmp_path)
    _PYTHON_HANDLERS[f"{tool}-archive-plans"]([])
    assert not old.exists()
    assert new.exists()
    archived = list((plans_dir / "archive").glob("*/*/*/old-plan.md"))
    assert len(archived) == 1


@pytest.mark.parametrize("tool", _TOOLS)
def test_archive_plans_dry_run(
    tool: str, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """--dry-run moves nothing."""
    plans_dir = tmp_path / f".{tool}" / "plans"
    plans_dir.mkdir(parents=True)
    old = _write_plan(plans_dir, "old-plan.md", age_days=30)
    monkeypatch.chdir(tmp_path)
    _PYTHON_HANDLERS[f"{tool}-archive-plans"](["--dry-run"])
    assert old.exists()
    assert not (plans_dir / "archive").exists()


@pytest.mark.parametrize("tool", _TOOLS)
def test_archive_plans_missing_dir(
    tool: str, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A missing plans directory exits with code 1."""
    monkeypatch.chdir(tmp_path)
    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS[f"{tool}-archive-plans"]([])
    assert exc_info.value.code == 1
