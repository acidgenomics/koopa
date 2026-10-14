"""Tests for koopa app obsidian bookmark."""

import json
from pathlib import Path

import pytest
from koopa.cli_app import _APP_TREE, _PYTHON_HANDLERS

_URL = "https://example.com/page?a=1&b=2"


def test_obsidian_bookmark_registered() -> None:
    """The handler and tree entry are registered."""
    assert _APP_TREE["obsidian"]["bookmark"] == "obsidian-bookmark"
    assert callable(_PYTHON_HANDLERS["obsidian-bookmark"])


def test_obsidian_bookmark_writes_dated_note(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A new link creates YYYY/MM/DD/bookmarks.md and is idempotent."""
    args = [_URL, "--title", "Example", "--date", "2026-10-14", "--vault-dir", str(tmp_path)]
    _PYTHON_HANDLERS["obsidian-bookmark"](args)
    note = tmp_path / "2026/10/14/bookmarks.md"
    assert note.read_text() == f"- [Example]({_URL})\n"
    assert "Added:" in capsys.readouterr().out
    _PYTHON_HANDLERS["obsidian-bookmark"](args)
    assert note.read_text() == f"- [Example]({_URL})\n"
    assert "Already present:" in capsys.readouterr().out


def test_obsidian_bookmark_appends_after_missing_newline(tmp_path: Path) -> None:
    """An existing note without a trailing newline keeps both entries on separate lines."""
    note = tmp_path / "2026/10/14/bookmarks.md"
    note.parent.mkdir(parents=True)
    note.write_text("- [Old](https://old.example)")
    _PYTHON_HANDLERS["obsidian-bookmark"](
        [_URL, "--date", "2026-10-14", "--vault-dir", str(tmp_path)]
    )
    assert note.read_text().splitlines() == ["- [Old](https://old.example)", f"- [{_URL}]({_URL})"]


def test_obsidian_bookmark_rejects_non_http_url(tmp_path: Path) -> None:
    """A non-HTTP(S) URL raises ValueError."""
    with pytest.raises(ValueError, match="absolute"):
        _PYTHON_HANDLERS["obsidian-bookmark"](["file:///etc/passwd", "--vault-dir", str(tmp_path)])


def test_obsidian_bookmark_resolves_symlinked_koopa_bucket(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """KOOPA_BUCKET is used, resolved through symlinks."""
    real = tmp_path / "real"
    real.mkdir()
    link = tmp_path / "link"
    link.symlink_to(real)
    monkeypatch.setenv("KOOPA_BUCKET", str(link))
    _PYTHON_HANDLERS["obsidian-bookmark"]([_URL, "--date", "2026-10-14"])
    assert (real / "2026/10/14/bookmarks.md").is_file()


def test_obsidian_bookmark_falls_back_to_registry(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """With no env vars, the open vault in Obsidian's registry is used."""
    vault = tmp_path / "vault"
    vault.mkdir()
    config = tmp_path / "obsidian.json"
    config.write_text(
        json.dumps(
            {
                "vaults": {
                    "a": {"path": str(tmp_path / "other"), "ts": 9},
                    "b": {"path": str(vault), "ts": 1, "open": True},
                }
            }
        )
    )
    monkeypatch.delenv("KOOPA_BUCKET", raising=False)
    monkeypatch.delenv("OBSIDIAN_VAULT_DIR", raising=False)
    monkeypatch.setattr("koopa.cli_app._OBSIDIAN_REGISTRY_CANDIDATES", (str(config),))
    _PYTHON_HANDLERS["obsidian-bookmark"]([_URL, "--date", "2026-10-14"])
    assert (vault.resolve() / "2026/10/14/bookmarks.md").is_file()


def test_obsidian_bookmark_no_vault_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    """No vault anywhere raises RuntimeError."""
    monkeypatch.delenv("KOOPA_BUCKET", raising=False)
    monkeypatch.delenv("OBSIDIAN_VAULT_DIR", raising=False)
    monkeypatch.setattr("koopa.cli_app._OBSIDIAN_REGISTRY_CANDIDATES", ())
    with pytest.raises(RuntimeError, match="No Obsidian vault"):
        _PYTHON_HANDLERS["obsidian-bookmark"]([_URL])
