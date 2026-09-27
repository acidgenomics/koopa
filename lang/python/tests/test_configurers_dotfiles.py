"""Tests for koopa.configurers.dotfiles helpers."""

import hashlib
import json
import os
import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.configurers import get_python_configurer, has_python_configurer
from koopa.configurers.dotfiles import (
    _chezmoi_entry_state,
    _chezmoi_managed,
    _chezmoiremove_targets,
    _is_chezmoi_copy,
    _print_chezmoi_status,
    _shield_user_files,
    _user_owned_remove_paths,
    _warn_cross_tree_overlap,
    _warn_remove_manage_conflict,
    main,
)


def test_has_python_configurer_falls_back_to_common_for_macos_user() -> None:
    """Concrete macos platform falls back to the common registry entry."""
    assert has_python_configurer("dotfiles", "macos", "user")
    assert has_python_configurer("color-mode", "macos", "user")


def test_get_python_configurer_falls_back_to_common_for_macos_user() -> None:
    """Concrete macos platform resolves to the common configurer's module."""
    assert get_python_configurer("dotfiles", "macos", "user") is main


def test_has_python_configurer_expands_common_to_os_id_like_family() -> None:
    """Generic common platform expands to the host's ID_LIKE family."""
    with (
        patch("koopa.system.get_os_id", return_value="ubuntu"),
        patch("koopa.system.get_os_id_like", return_value="debian"),
        patch("koopa.system.is_macos", return_value=False),
    ):
        assert has_python_configurer("base", "common", "system")


# ---------------------------------------------------------------------------
# _warn_cross_tree_overlap
# ---------------------------------------------------------------------------


def test_warn_cross_tree_overlap_empty(capsys: pytest.CaptureFixture[str]) -> None:
    """No warning when there is no overlap."""
    _warn_cross_tree_overlap("work", {".bashrc", ".config/git/config"}, {".bashrc-work"})
    captured = capsys.readouterr()
    assert "Warning" not in captured.err
    assert "Warning" not in captured.out


def test_warn_cross_tree_overlap_nonempty(capsys: pytest.CaptureFixture[str]) -> None:
    """Warning lists every colliding path when overlap is non-empty."""
    main = {".bashrc", ".config/git/config", ".npmrc"}
    work = {".bashrc", ".npmrc", ".bashrc-work"}
    _warn_cross_tree_overlap("work", main, work)
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Warning" in combined
    assert ".bashrc" in combined
    assert ".npmrc" in combined
    assert ".config/git/config" not in combined  # not in overlap


def test_warn_cross_tree_overlap_label(capsys: pytest.CaptureFixture[str]) -> None:
    """Warning includes the tree label."""
    _warn_cross_tree_overlap("private", {".zshrc"}, {".zshrc"})
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "private" in combined


def test_warn_cross_tree_overlap_count(capsys: pytest.CaptureFixture[str]) -> None:
    """Warning reports the correct collision count."""
    overlap = {".a", ".b", ".c"}
    _warn_cross_tree_overlap("work", overlap, overlap)
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "3" in combined


# ---------------------------------------------------------------------------
# _chezmoi_managed
# ---------------------------------------------------------------------------


def test_chezmoi_managed_absent_source(tmp_path: Path) -> None:
    """Returns empty set without calling subprocess when source dir is absent."""
    result = _chezmoi_managed("/usr/bin/chezmoi", str(tmp_path / "nonexistent"), {})
    assert result == set()


def test_chezmoi_managed_parses_stdout(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Parses stdout into a stripped set; blank lines are dropped."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    fake_output = ".bashrc\n.config/git/config\n\n  .npmrc  \n"

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout=fake_output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_managed("/usr/bin/chezmoi", str(source), {})
    assert result == {".bashrc", ".config/git/config", ".npmrc"}


def test_chezmoi_managed_subprocess_error(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Returns empty set on CalledProcessError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        raise subprocess.CalledProcessError(1, args)

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_managed("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoi_managed_oserror(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Returns empty set on OSError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(_args: list[str], **__: object) -> subprocess.CompletedProcess:
        raise OSError("not found")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_managed("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoi_managed_passes_config(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Passes --config= to argv when config is provided."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoi_managed("/usr/bin/chezmoi", str(source), {}, config="/some/chezmoi.toml")
    assert any("--config=/some/chezmoi.toml" in a for a in captured_args[0])


def test_chezmoi_managed_omits_config_when_none(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Does not include --config= in argv when config is None."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoi_managed("/usr/bin/chezmoi", str(source), {}, config=None)
    assert not any("--config" in a for a in captured_args[0])


# ---------------------------------------------------------------------------
# _chezmoiremove_targets
# ---------------------------------------------------------------------------


def test_chezmoiremove_targets_absent_file(tmp_path: Path) -> None:
    """Returns empty set without calling subprocess when .chezmoiremove is absent."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    result = _chezmoiremove_targets("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoiremove_targets_parses_stdout(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Parses rendered stdout into a set; blanks, comments, and negations handled."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    (source / ".chezmoiremove").write_text(".claude/skills/todo-org\n")
    fake_output = ".claude/skills/todo-org\n\n# a comment\n!.claude/skills/keep\n"

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout=fake_output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoiremove_targets("/usr/bin/chezmoi", str(source), {})
    assert result == {".claude/skills/todo-org", ".claude/skills/keep"}


def test_chezmoiremove_targets_subprocess_error(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Returns empty set on CalledProcessError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    (source / ".chezmoiremove").write_text(".claude/skills/todo-org\n")

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        raise subprocess.CalledProcessError(1, args)

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoiremove_targets("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoiremove_targets_oserror(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Returns empty set on OSError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    (source / ".chezmoiremove").write_text(".claude/skills/todo-org\n")

    def fake_run(_args: list[str], **__: object) -> subprocess.CompletedProcess:
        raise OSError("not found")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoiremove_targets("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoiremove_targets_passes_config(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Passes --config= to argv when config is provided."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    (source / ".chezmoiremove").write_text(".claude/skills/todo-org\n")
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoiremove_targets("/usr/bin/chezmoi", str(source), {}, config="/some/chezmoi.toml")
    assert any("--config=/some/chezmoi.toml" in a for a in captured_args[0])


def test_chezmoiremove_targets_omits_config_when_none(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Does not include --config= in argv when config is None."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    (source / ".chezmoiremove").write_text(".claude/skills/todo-org\n")
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoiremove_targets("/usr/bin/chezmoi", str(source), {}, config=None)
    assert not any("--config" in a for a in captured_args[0])


# ---------------------------------------------------------------------------
# _warn_remove_manage_conflict
# ---------------------------------------------------------------------------


def test_warn_remove_manage_conflict_empty(capsys: pytest.CaptureFixture[str]) -> None:
    """No warning when the removal list does not collide with managed targets."""
    _warn_remove_manage_conflict(
        "work", {".claude/skills/todo-org/SKILL.md"}, {".claude/skills/other"}
    )
    captured = capsys.readouterr()
    assert "Warning" not in captured.err
    assert "Warning" not in captured.out


def test_warn_remove_manage_conflict_directory_ancestor(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Warns when a removed directory is an ancestor of a managed file.

    This is the real-world case: chezmoi managed lists the file
    (.claude/skills/todo-org/SKILL.md), while .chezmoiremove names the
    directory (.claude/skills/todo-org). A plain set intersection would miss it.
    """
    _warn_remove_manage_conflict(
        "work",
        {".claude/skills/todo-org/SKILL.md"},
        {".claude/skills/todo-org"},
    )
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Warning" in combined
    assert "work" in combined
    assert ".claude/skills/todo-org/SKILL.md" in combined


def test_warn_remove_manage_conflict_prefix_near_miss(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Does not warn on a same-prefix path that is not a true ancestor.

    ".claude/skills/todo" is a string-prefix of the managed path but not a
    path-ancestor (no separator boundary) — must not false-positive.
    """
    _warn_remove_manage_conflict(
        "work",
        {".claude/skills/todo-org/SKILL.md"},
        {".claude/skills/todo"},
    )
    captured = capsys.readouterr()
    assert "Warning" not in captured.err
    assert "Warning" not in captured.out


# ---------------------------------------------------------------------------
# _print_chezmoi_status
# ---------------------------------------------------------------------------


def test_print_chezmoi_status_absent_source(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """No output when source dir is absent."""
    _print_chezmoi_status("/usr/bin/chezmoi", str(tmp_path / "nonexistent"), {})
    captured = capsys.readouterr()
    assert captured.err == ""
    assert captured.out == ""


def test_print_chezmoi_status_no_changes(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Emits 'No pending changes' note when status output is empty."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _print_chezmoi_status("/usr/bin/chezmoi", str(source), {})
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "No pending changes" in combined


def test_print_chezmoi_status_with_changes(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Emits 'Pending changes (N)' header and each status line."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    fake_output = "MM .config/git/config\n M .bashrc\n"

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout=fake_output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _print_chezmoi_status("/usr/bin/chezmoi", str(source), {})
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Pending changes (2)" in combined
    assert ".config/git/config" in combined
    assert ".bashrc" in combined


# ---------------------------------------------------------------------------
# _chezmoi_entry_state
# ---------------------------------------------------------------------------


def test_chezmoi_entry_state_absent_source(tmp_path: Path) -> None:
    """Returns empty dict without calling subprocess when source dir is absent."""
    result = _chezmoi_entry_state("/usr/bin/chezmoi", str(tmp_path / "nonexistent"), {})
    assert result == {}


def test_chezmoi_entry_state_parses_json(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Parses the entryState map out of the dumped JSON."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    fake_output = json.dumps({"entryState": {"/home/user/.bashrc": {"type": "file"}}})

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout=fake_output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_entry_state("/usr/bin/chezmoi", str(source), {})
    assert result == {"/home/user/.bashrc": {"type": "file"}}


def test_chezmoi_entry_state_missing_entry_state_key(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Returns empty dict when the JSON has no entryState key."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout="{}", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_entry_state("/usr/bin/chezmoi", str(source), {})
    assert result == {}


def test_chezmoi_entry_state_invalid_json(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Returns empty dict on unparseable stdout — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout="not json", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_entry_state("/usr/bin/chezmoi", str(source), {})
    assert result == {}


def test_chezmoi_entry_state_subprocess_error(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Returns empty dict on CalledProcessError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        raise subprocess.CalledProcessError(1, args)

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_entry_state("/usr/bin/chezmoi", str(source), {})
    assert result == {}


def test_chezmoi_entry_state_passes_config(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Passes --config= to argv when config is provided."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="{}", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoi_entry_state("/usr/bin/chezmoi", str(source), {}, config="/some/chezmoi.toml")
    assert any("--config=/some/chezmoi.toml" in a for a in captured_args[0])


# ---------------------------------------------------------------------------
# _is_chezmoi_copy
# ---------------------------------------------------------------------------


def test_is_chezmoi_copy_no_entry(tmp_path: Path) -> None:
    """No entry at all counts as not chezmoi's copy."""
    path = tmp_path / "file.txt"
    path.write_text("hello")
    assert _is_chezmoi_copy(str(path), None) is False


def test_is_chezmoi_copy_matching_file(tmp_path: Path) -> None:
    """A file whose content sha256 matches the entry is chezmoi's copy."""
    path = tmp_path / "file.txt"
    path.write_text("hello")
    sha = hashlib.sha256(b"hello").hexdigest()
    entry: dict[str, object] = {"type": "file", "contentsSHA256": sha}
    assert _is_chezmoi_copy(str(path), entry) is True


def test_is_chezmoi_copy_modified_file(tmp_path: Path) -> None:
    """A file whose content no longer matches the entry is not chezmoi's copy."""
    path = tmp_path / "file.txt"
    path.write_text("edited by the user")
    sha = hashlib.sha256(b"hello").hexdigest()
    entry: dict[str, object] = {"type": "file", "contentsSHA256": sha}
    assert _is_chezmoi_copy(str(path), entry) is False


def test_is_chezmoi_copy_matching_symlink(tmp_path: Path) -> None:
    """A symlink whose target-string sha256 matches the entry is chezmoi's copy."""
    target = "../elsewhere/target"
    link = tmp_path / "link"
    link.symlink_to(target)
    sha = hashlib.sha256(target.encode()).hexdigest()
    entry: dict[str, object] = {"type": "symlink", "contentsSHA256": sha}
    assert _is_chezmoi_copy(str(link), entry) is True


def test_is_chezmoi_copy_repointed_symlink(tmp_path: Path) -> None:
    """A symlink repointed elsewhere by the user is not chezmoi's copy."""
    link = tmp_path / "link"
    link.symlink_to("/somewhere/else")
    sha = hashlib.sha256(b"/original/target").hexdigest()
    entry: dict[str, object] = {"type": "symlink", "contentsSHA256": sha}
    assert _is_chezmoi_copy(str(link), entry) is False


def test_is_chezmoi_copy_type_mismatch(tmp_path: Path) -> None:
    """A symlink where the entry says 'file' is not chezmoi's copy."""
    target = "elsewhere"
    link = tmp_path / "link"
    link.symlink_to(target)
    sha = hashlib.sha256(target.encode()).hexdigest()
    entry: dict[str, object] = {"type": "file", "contentsSHA256": sha}
    assert _is_chezmoi_copy(str(link), entry) is False


def test_is_chezmoi_copy_missing_path(tmp_path: Path) -> None:
    """A path that no longer exists is not chezmoi's copy."""
    sha = hashlib.sha256(b"hello").hexdigest()
    entry: dict[str, object] = {"type": "file", "contentsSHA256": sha}
    assert _is_chezmoi_copy(str(tmp_path / "gone.txt"), entry) is False


def test_is_chezmoi_copy_missing_sha_field(tmp_path: Path) -> None:
    """An entry with no contentsSHA256 (e.g. a 'remove' record) is not a copy."""
    path = tmp_path / "file.txt"
    path.write_text("hello")
    assert _is_chezmoi_copy(str(path), {"type": "remove"}) is False


# ---------------------------------------------------------------------------
# _user_owned_remove_paths
# ---------------------------------------------------------------------------


def test_user_owned_remove_paths_unchanged_file_not_listed(tmp_path: Path) -> None:
    """An unmodified file at a remove target is not returned."""
    (tmp_path / "rules").mkdir()
    path = tmp_path / "rules" / "lessons.md"
    path.write_text("chezmoi content")
    sha = hashlib.sha256(b"chezmoi content").hexdigest()
    state: dict[str, dict[str, object]] = {str(path): {"type": "file", "contentsSHA256": sha}}
    result = _user_owned_remove_paths(str(tmp_path), {"rules/lessons.md"}, state)
    assert result == []


def test_user_owned_remove_paths_changed_file_listed(tmp_path: Path) -> None:
    """A user-edited file at a remove target is returned."""
    (tmp_path / "rules").mkdir()
    path = tmp_path / "rules" / "lessons.md"
    path.write_text("my own notes")
    sha = hashlib.sha256(b"chezmoi content").hexdigest()
    state: dict[str, dict[str, object]] = {str(path): {"type": "file", "contentsSHA256": sha}}
    result = _user_owned_remove_paths(str(tmp_path), {"rules/lessons.md"}, state)
    assert result == [str(path)]


def test_user_owned_remove_paths_no_state_entry_listed(tmp_path: Path) -> None:
    """A file with no matching state entry is treated as user-owned."""
    (tmp_path / "rules").mkdir()
    path = tmp_path / "rules" / "lessons.md"
    path.write_text("anything")
    result = _user_owned_remove_paths(str(tmp_path), {"rules/lessons.md"}, {})
    assert result == [str(path)]


def test_user_owned_remove_paths_missing_target_ignored(tmp_path: Path) -> None:
    """A remove target that does not exist on disk is silently skipped."""
    result = _user_owned_remove_paths(str(tmp_path), {"rules/gone.md"}, {})
    assert result == []


def test_user_owned_remove_paths_directory_mixed_contents(tmp_path: Path) -> None:
    """Only the user-owned file inside a directory target is returned."""
    skill_dir = tmp_path / "skills" / "foo"
    skill_dir.mkdir(parents=True)
    unchanged = skill_dir / "SKILL.md"
    unchanged.write_text("chezmoi content")
    extra = skill_dir / "notes.md"
    extra.write_text("my own notes")
    sha = hashlib.sha256(b"chezmoi content").hexdigest()
    state: dict[str, dict[str, object]] = {str(unchanged): {"type": "file", "contentsSHA256": sha}}
    result = _user_owned_remove_paths(str(tmp_path), {"skills/foo"}, state)
    assert result == [str(extra)]


def test_user_owned_remove_paths_symlink_target(tmp_path: Path) -> None:
    """A symlink remove target is checked as a leaf, matching its own record."""
    link = tmp_path / "link"
    link.symlink_to("elsewhere")
    sha = hashlib.sha256(b"elsewhere").hexdigest()
    state: dict[str, dict[str, object]] = {str(link): {"type": "symlink", "contentsSHA256": sha}}
    result = _user_owned_remove_paths(str(tmp_path), {"link"}, state)
    assert result == []


# ---------------------------------------------------------------------------
# _shield_user_files
# ---------------------------------------------------------------------------


def test_shield_user_files_no_paths_is_noop(capsys: pytest.CaptureFixture[str]) -> None:
    """An empty path list yields with no warning and no filesystem changes."""
    with _shield_user_files("main", []):
        pass
    captured = capsys.readouterr()
    assert "Warning" not in captured.err + captured.out


def test_shield_user_files_restores_after_success(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A shielded file is moved away, then restored once the block exits."""
    home = tmp_path / "home"
    home.mkdir()
    monkeypatch.setattr(os.path, "expanduser", lambda p: str(home) if p == "~" else p)
    monkeypatch.setattr(
        "koopa.configurers.dotfiles.xdg_cache_home", lambda: str(tmp_path / "cache")
    )
    target = home / "rules" / "lessons.md"
    target.parent.mkdir()
    target.write_text("my own notes")

    with _shield_user_files("main", [str(target)]):
        assert not target.exists()

    assert target.read_text() == "my own notes"


def test_shield_user_files_restores_after_exception(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A shielded file is restored even when the block raises."""
    home = tmp_path / "home"
    home.mkdir()
    monkeypatch.setattr(os.path, "expanduser", lambda p: str(home) if p == "~" else p)
    monkeypatch.setattr(
        "koopa.configurers.dotfiles.xdg_cache_home", lambda: str(tmp_path / "cache")
    )
    target = home / "rules" / "lessons.md"
    target.parent.mkdir()
    target.write_text("my own notes")

    with pytest.raises(RuntimeError), _shield_user_files("main", [str(target)]):
        raise RuntimeError("boom")

    assert target.read_text() == "my own notes"


def test_shield_user_files_keeps_stash_on_collision(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A path recreated during the block is not overwritten; the stash survives."""
    home = tmp_path / "home"
    home.mkdir()
    monkeypatch.setattr(os.path, "expanduser", lambda p: str(home) if p == "~" else p)
    cache_dir = tmp_path / "cache"
    monkeypatch.setattr("koopa.configurers.dotfiles.xdg_cache_home", lambda: str(cache_dir))
    target = home / "rules" / "lessons.md"
    target.parent.mkdir()
    target.write_text("my own notes")

    with _shield_user_files("main", [str(target)]):
        target.write_text("recreated by the tree's install script")

    captured = capsys.readouterr()
    assert "recreated" in captured.err + captured.out
    assert target.read_text() == "recreated by the tree's install script"
    stash_root = cache_dir / "koopa"
    remaining = list(stash_root.rglob("lessons.md"))
    assert len(remaining) == 1
    assert remaining[0].read_text() == "my own notes"
