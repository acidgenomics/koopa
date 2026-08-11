"""CLI develop dispatch module unit tests."""

import gzip
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.cli_develop import (
    _DEVELOP_HANDLERS,
    _detect_color_mode_thrash,
    _skill_frontmatter_errors,
    _version_from_filename,
)


def test_handlers_not_empty() -> None:
    """Test that _DEVELOP_HANDLERS has entries."""
    assert len(_DEVELOP_HANDLERS) > 0


def test_handlers_all_callable() -> None:
    """Test that all handler values are callable."""
    for name, handler in _DEVELOP_HANDLERS.items():
        assert callable(handler), f"Handler for '{name}' is not callable"


def test_handlers_expected_commands() -> None:
    """Test that key develop commands are registered."""
    expected = [
        "activation-fork-audit",
        "activation-speed-test",
        "cache-functions",
        "check-skills",
        "color-mode-audit",
        "generate-completion",
        "shellcheck",
    ]
    for cmd in expected:
        assert cmd in _DEVELOP_HANDLERS, f"Expected command '{cmd}' not in _DEVELOP_HANDLERS"


def test_activation_speed_test_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test activation-speed-test --help exits cleanly."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["activation-speed-test"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "threshold" in captured.out.lower()


def test_activation_fork_audit_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test activation-fork-audit --help exits cleanly."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["activation-fork-audit"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "fork" in captured.out.lower()


def test_activation_fork_audit_passes(capsys: pytest.CaptureFixture[str]) -> None:
    """Test that the current codebase passes the fork audit at current thresholds."""
    # This test enforces that activation-path fork counts do not regress.
    # If this test fails, a recent change added unnecessary subprocess forks
    # to the shell activation path. Check the --verbose output for culprits.
    _DEVELOP_HANDLERS["activation-fork-audit"](["--verbose"])
    captured = capsys.readouterr()
    assert "PASS" in captured.out
    assert "FAIL" not in captured.out


# ---------------------------------------------------------------------------
# _detect_color_mode_thrash unit tests
# ---------------------------------------------------------------------------


def test_detect_color_mode_thrash_healthy() -> None:
    """A log with one genuine toggle and stabilization is not thrash."""
    lines = [
        "▸ Applying color mode: dark\n",
        "** Color mode already applied: dark\n",
        "** Color mode already applied: dark\n",
        "▸ Applying color mode: light\n",  # legitimate user toggle
        "** Color mode already applied: light\n",
        "** Color mode already applied: light\n",
    ]
    longest, _ = _detect_color_mode_thrash(lines)
    assert longest < 4


def test_detect_color_mode_thrash_detected() -> None:
    """Four consecutive alternating applies with no stabilization is thrash."""
    lines = [
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
    ]
    longest, run = _detect_color_mode_thrash(lines)
    assert longest >= 4
    modes = [m for m, _ in run]
    # Verify the run strictly alternates.
    for i in range(1, len(modes)):
        assert modes[i] != modes[i - 1], "run should strictly alternate"


def test_detect_color_mode_thrash_stabilization_resets_run() -> None:
    """An 'already applied' line between applies resets the run counter."""
    lines = [
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "** Color mode already applied: dark\n",  # stabilization — reset
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
    ]
    longest, _ = _detect_color_mode_thrash(lines)
    # The first burst is length 3, reset, then another 2 — no burst reaches 4.
    assert longest < 4


def test_detect_color_mode_thrash_tolerates_prefixes() -> None:
    """Lines with ▸/** alert prefixes and plain lines both parse correctly."""
    lines_with_prefix = [
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
    ]
    lines_plain = [
        "Applying color mode: dark\n",
        "Applying color mode: light\n",
        "Applying color mode: dark\n",
        "Applying color mode: light\n",
    ]
    longest_prefix, _ = _detect_color_mode_thrash(lines_with_prefix)
    longest_plain, _ = _detect_color_mode_thrash(lines_plain)
    assert longest_prefix == 4
    assert longest_plain == 4


def test_detect_color_mode_thrash_parses_timestamps() -> None:
    """ISO-8601 timestamps are captured and detection still triggers."""
    lines = [
        "[2026-06-06T19:46:47-04:00] Applying color mode: light\n",
        "[2026-06-06T19:46:48-04:00] Applying color mode: dark\n",
        "[2026-06-06T19:46:49-04:00] Applying color mode: light\n",
        "[2026-06-06T19:46:50-04:00] Applying color mode: dark\n",
    ]
    longest, run = _detect_color_mode_thrash(lines)
    assert longest >= 4
    # Timestamps should be captured.
    timestamps = [ts for _, ts in run]
    assert all(ts is not None for ts in timestamps)
    assert timestamps[0] == "2026-06-06T19:46:47-04:00"
    assert timestamps[-1] == "2026-06-06T19:46:50-04:00"


def test_detect_color_mode_thrash_untimestamped_returns_none_ts() -> None:
    """Lines without timestamps return None for the timestamp field."""
    lines = [
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
    ]
    longest, run = _detect_color_mode_thrash(lines)
    assert longest >= 4
    assert all(ts is None for _, ts in run)


def test_detect_color_mode_thrash_empty_log() -> None:
    """An empty log returns zero length and empty run."""
    longest, run = _detect_color_mode_thrash([])
    assert longest == 0
    assert run == []


# ---------------------------------------------------------------------------
# _handle_color_mode_audit integration tests (via temp log files)
# ---------------------------------------------------------------------------


def test_color_mode_audit_help(capsys: pytest.CaptureFixture[str]) -> None:
    """--help exits cleanly with usage info."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["color-mode-audit"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "thrash" in captured.out.lower()


def test_color_mode_audit_passes_on_clean_log(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A log with no thrash produces PASS and exit 0."""
    log = tmp_path / "color-mode-sync.log"
    log.write_text(
        "▸ Applying color mode: dark\n"
        "** Color mode already applied: dark\n"
        "** Color mode already applied: dark\n"
        "▸ Applying color mode: light\n"
        "** Color mode already applied: light\n"
    )
    _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(log)])
    captured = capsys.readouterr()
    assert "PASS" in captured.out
    assert "FAIL" not in captured.out


def test_color_mode_audit_fails_on_thrash_log(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A log with thrash produces FAIL and exit 1."""
    log = tmp_path / "color-mode-sync.log"
    log.write_text(
        "▸ Applying color mode: light\n"
        "▸ Applying color mode: dark\n"
        "▸ Applying color mode: light\n"
        "▸ Applying color mode: dark\n"
    )
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(log)])
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "FAIL" in captured.out


def test_color_mode_audit_verbose_on_thrash(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """--verbose reports the mode sequence on a thrashing log."""
    log = tmp_path / "color-mode-sync.log"
    log.write_text(
        "[2026-06-06T19:46:47-04:00] Applying color mode: light\n"
        "[2026-06-06T19:46:48-04:00] Applying color mode: dark\n"
        "[2026-06-06T19:46:49-04:00] Applying color mode: light\n"
        "[2026-06-06T19:46:50-04:00] Applying color mode: dark\n"
    )
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(log), "--verbose"])
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "FAIL" in captured.out
    assert "light" in captured.out
    assert "dark" in captured.out
    assert "2026-06-06T19:46:47" in captured.out


def test_color_mode_audit_missing_log_is_pass(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A missing --log path produces PASS (no log = nothing to complain about)."""
    _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(tmp_path / "nonexistent.log")])
    captured = capsys.readouterr()
    assert "PASS" in captured.out


# -- check-skills ---------------------------------------------------------------

_CLEAN_SKILL_MD = """---
name: example
description: >-
  A short description under the budget.
---

# Example
"""


def _write_skill(tmp_path: Path, name: str, content: str) -> Path:
    """Write a SKILL.md under tmp_path/name/SKILL.md and return its root dir."""
    skill_dir = tmp_path / name
    skill_dir.mkdir()
    (skill_dir / "SKILL.md").write_text(content)
    return tmp_path


def test_check_skills_help(capsys: pytest.CaptureFixture[str]) -> None:
    """--help exits cleanly with usage info."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["check-skills"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "frontmatter" in captured.out.lower()


def test_check_skills_passes_on_clean_skill(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A skill using 'description: >-' within budget passes with exit 0."""
    root = _write_skill(tmp_path, "example", _CLEAN_SKILL_MD)
    _DEVELOP_HANDLERS["check-skills"]([str(root)])
    captured = capsys.readouterr()
    assert "passed" in captured.err.lower() or "passed" in captured.out.lower()


def test_check_skills_fails_on_plain_folded_scalar(tmp_path: Path) -> None:
    """A plain 'description: >' fails, since it adds a trailing-newline char."""
    content = _CLEAN_SKILL_MD.replace("description: >-", "description: >")
    root = _write_skill(tmp_path, "example", content)
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["check-skills"]([str(root)])
    assert exc_info.value.code == 1


def test_check_skills_fails_on_inline_description(tmp_path: Path) -> None:
    """An inline (non-block-scalar) description fails."""
    content = """---
name: example
description: An inline description on one line.
---
"""
    root = _write_skill(tmp_path, "example", content)
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["check-skills"]([str(root)])
    assert exc_info.value.code == 1


def test_check_skills_fails_on_missing_frontmatter(tmp_path: Path) -> None:
    """A SKILL.md with no frontmatter delimiters fails."""
    root = _write_skill(tmp_path, "example", "# Example\n\nNo frontmatter here.\n")
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["check-skills"]([str(root)])
    assert exc_info.value.code == 1


def test_check_skills_no_skills_found_errors(tmp_path: Path) -> None:
    """An empty root directory (no SKILL.md files) is an error, not a silent pass."""
    empty_root = tmp_path / "empty"
    empty_root.mkdir()
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["check-skills"]([str(empty_root)])
    assert exc_info.value.code == 1


def test_check_skills_repo_trees_pass() -> None:
    """The real koopa skill trees (post-normalization) pass check-skills."""
    _DEVELOP_HANDLERS["check-skills"]([])


@pytest.mark.parametrize(
    ("length", "should_fail"),
    [(1023, False), (1024, True)],
)
def test_skill_frontmatter_errors_length_boundary(
    tmp_path: Path,
    length: int,
    should_fail: bool,
) -> None:
    """1023 raw chars passes; 1024 fails — the exact Agent Skills spec budget boundary."""
    description = "x" * length
    content = f"""---
name: example
description: >-
  {description}
---
"""
    root = _write_skill(tmp_path, "example", content)
    errors = _skill_frontmatter_errors(str(root / "example" / "SKILL.md"))
    assert bool(errors) is should_fail


# -- push-installer: version derivation from filename -------------------------


@pytest.mark.parametrize(
    ("app", "filename", "expected"),
    [
        ("cellranger", "cellranger-10.0.0.tar.gz", "10.0.0"),
        ("bcl-convert", "bcl-convert-4.5.4-linux-x86_64.tar.xz", "4.5.4"),
        ("cellranger", "10.0.0.tar.xz", "10.0.0"),
        ("cellranger", "cellranger.tar.gz", None),
    ],
)
def test_version_from_filename(app: str, filename: str, expected: str | None) -> None:
    """Test that a version is best-effort extracted from a vendor tarball filename."""
    assert _version_from_filename(app, filename) == expected


# -- push-installer: no 'installer_artifact' declared --------------------------


def test_push_installer_errors_when_field_missing(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """push-installer exits 1 when the app has no 'installer_artifact' in app.json."""
    tarball = tmp_path / "ripgrep-14.1.0.tar.gz"
    with gzip.open(tarball, "wb") as fh:
        fh.write(b"not a real tar, just needs valid gzip magic bytes")
    with (
        patch("koopa.install._has_private_access", return_value=True),
        patch("shutil.which", return_value="/usr/bin/aws"),
        patch("koopa.io.import_app_json", return_value={"ripgrep": {"version": "14.0.0"}}),
        pytest.raises(SystemExit) as exc_info,
    ):
        _DEVELOP_HANDLERS["push-installer"](["ripgrep", str(tarball)])
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "installer_artifact" in captured.err


def test_push_installer_errors_without_private_access(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """push-installer exits 1 when the acidgenomics AWS profile isn't available."""
    tarball = tmp_path / "cellranger-10.0.0.tar.gz"
    with gzip.open(tarball, "wb") as fh:
        fh.write(b"not a real tar, just needs valid gzip magic bytes")
    with (
        patch("koopa.install._has_private_access", return_value=False),
        pytest.raises(SystemExit) as exc_info,
    ):
        _DEVELOP_HANDLERS["push-installer"](["cellranger", str(tarball)])
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "private access" in captured.err.lower() or "acidgenomics" in captured.err


# -- scrub-install-info ---------------------------------------------------


_DUMMY_SECRET_VALUE = "super-secret-token-value-should-never-print"


def _write_scrubbable_info(tmp_path: Path) -> Path:
    import json

    install_dir = tmp_path / "app" / "myapp" / "1.0" / ".install"
    install_dir.mkdir(parents=True)
    info_file = install_dir / "info.json"
    info_file.write_text(
        json.dumps(
            {
                "name": "myapp",
                "environ": {"PATH": "/usr/bin", "SOME_TOKEN": _DUMMY_SECRET_VALUE},
            },
        ),
    )
    return info_file


def test_scrub_install_info_reports_and_writes(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """scrub-install-info rewrites the file and reports only the removed key name."""
    import json

    info_file = _write_scrubbable_info(tmp_path)

    with patch("koopa.prefix.app_prefix", return_value=str(tmp_path / "app")):
        _DEVELOP_HANDLERS["scrub-install-info"](["myapp"])

    captured = capsys.readouterr()
    assert "SOME_TOKEN" in captured.err
    assert _DUMMY_SECRET_VALUE not in captured.err
    written = json.loads(info_file.read_text())
    assert written["environ"] == {"PATH": "/usr/bin"}


def test_scrub_install_info_dry_run_reports_without_writing(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """scrub-install-info --dry-run reports without modifying the file."""
    info_file = _write_scrubbable_info(tmp_path)
    original_text = info_file.read_text()

    with patch("koopa.prefix.app_prefix", return_value=str(tmp_path / "app")):
        _DEVELOP_HANDLERS["scrub-install-info"](["myapp", "--dry-run"])

    captured = capsys.readouterr()
    assert "Would scrub" in captured.err
    assert info_file.read_text() == original_text
