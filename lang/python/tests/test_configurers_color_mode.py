"""Tests for koopa.configurers.color_mode helpers."""

import subprocess
from pathlib import Path

import pytest
from koopa.configurers.color_mode import (
    _apply_color_mode_tree,
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


def test_discover_color_mode_targets_warn_on_drop_false_is_silent(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """warn_on_drop=False drops unmanaged targets without printing a warning.

    main()'s multi-tree apply relies on this: a target one tree drops (e.g.
    .claude/settings.json excluded from the main tree while a work-tree marker is
    present) may still be legitimately managed by a later tree, so warning at
    this call site would be a permanent false alarm on every flip.
    """
    chezmoi_prefix = tmp_path / "chezmoi"
    _write_tmpl(chezmoi_prefix, "dot_claude/settings.json.tmpl", b"KOOPA_COLOR_MODE")

    targets = _discover_color_mode_targets(str(chezmoi_prefix), managed=set(), warn_on_drop=False)
    assert targets == []
    captured = capsys.readouterr()
    assert "Warning" not in (captured.err + captured.out)


# ---------------------------------------------------------------------------
# _apply_color_mode_tree
# ---------------------------------------------------------------------------


def test_apply_color_mode_tree_absent_source_is_noop(tmp_path: Path) -> None:
    """A tree whose source directory doesn't exist (no work/private tree) is skipped."""
    result = _apply_color_mode_tree(
        "/usr/bin/chezmoi",
        {},
        "work",
        str(tmp_path / "nonexistent"),
        None,
        verbose=False,
        required=False,
    )
    assert result == (set(), set())


def test_apply_color_mode_tree_unmanaged_target_now_applied_by_overlay_tree(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """The exact regression this fix closes: a work-tree-managed target is applied.

    .claude/settings.json is unmanaged by the main tree (chezmoiignore'd whenever a
    work-tree marker is present) but managed by the work tree. Applying the work
    tree must actually run chezmoi apply against it and report it in applied_rels.
    """
    source = tmp_path / "chezmoi"
    _write_tmpl(source, "dot_claude/settings.json.tmpl", b"KOOPA_COLOR_MODE")
    target_rel = ".claude/settings.json"
    captured_args: list[list[str]] = []

    def fake_managed(*_a: object, **_kw: object) -> set[str]:
        return {target_rel}

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr("koopa.configurers.color_mode._chezmoi_managed", fake_managed)
    monkeypatch.setattr(subprocess, "run", fake_run)

    result = _apply_color_mode_tree(
        "/usr/bin/chezmoi",
        {},
        "work",
        str(source),
        "/work/chezmoi.toml",
        verbose=False,
        required=False,
    )
    assert result is not None
    candidate_rels, applied_rels = result
    assert candidate_rels == {target_rel}
    assert applied_rels == {target_rel}
    assert any(target_rel in arg for call in captured_args for arg in call)
    assert any("--config=/work/chezmoi.toml" in arg for call in captured_args for arg in call)
    captured = capsys.readouterr()
    assert "Warning" not in (captured.err + captured.out)


def test_apply_color_mode_tree_probe_failure_never_raises(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """An empty managed set warns and skips this tree, even when required=True.

    _chezmoi_managed() degrades to an empty set on probe failure by design and
    must never block the configure run -- inverting an empty result into "apply
    everything" would reintroduce the original whole-apply-abort bug.  required
    only gates apply-subprocess failure handling, not probe failure.
    """
    source = tmp_path / "chezmoi"
    source.mkdir()

    monkeypatch.setattr("koopa.configurers.color_mode._chezmoi_managed", lambda *_a, **_kw: set())

    result = _apply_color_mode_tree(
        "/usr/bin/chezmoi", {}, "main", str(source), None, verbose=False, required=True
    )
    assert result is None


def test_apply_color_mode_tree_required_apply_failure_raises(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """required=True re-raises an apply-subprocess failure (the main tree)."""
    source = tmp_path / "chezmoi"
    _write_tmpl(source, "dot_config/bat/config.tmpl", b"KOOPA_COLOR_MODE")
    target_rel = ".config/bat/config"

    monkeypatch.setattr(
        "koopa.configurers.color_mode._chezmoi_managed", lambda *_a, **_kw: {target_rel}
    )

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        raise subprocess.CalledProcessError(1, args)

    monkeypatch.setattr(subprocess, "run", fake_run)

    with pytest.raises(subprocess.CalledProcessError):
        _apply_color_mode_tree(
            "/usr/bin/chezmoi", {}, "main", str(source), None, verbose=False, required=True
        )


def test_apply_color_mode_tree_non_required_apply_failure_warns_and_continues(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """required=False warns on an apply-subprocess failure and returns no applied targets.

    A permanently broken work/private tree must never raise here -- doing so would
    reintroduce the documented infinite-respawn wedge, where the applied-marker is
    never written and every new shell retries the identical failure.
    """
    source = tmp_path / "chezmoi"
    _write_tmpl(source, "dot_claude/settings.json.tmpl", b"KOOPA_COLOR_MODE")
    target_rel = ".claude/settings.json"

    monkeypatch.setattr(
        "koopa.configurers.color_mode._chezmoi_managed", lambda *_a, **_kw: {target_rel}
    )

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        raise subprocess.CalledProcessError(1, args)

    monkeypatch.setattr(subprocess, "run", fake_run)

    result = _apply_color_mode_tree(
        "/usr/bin/chezmoi", {}, "work", str(source), None, verbose=False, required=False
    )
    assert result is not None
    candidate_rels, applied_rels = result
    assert candidate_rels == {target_rel}
    assert applied_rels == set()
    captured = capsys.readouterr()
    assert "Warning" in (captured.err + captured.out)
