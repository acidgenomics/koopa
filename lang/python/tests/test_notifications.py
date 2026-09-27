"""Unit tests for koopa.notifications."""

import json
import subprocess
import urllib.error
from unittest.mock import patch

import pytest
from koopa.notifications import compare_release_notifications, fetch_release_notifications
from koopa.version_check import VersionCheckResult

# -- Fixtures for compare_release_notifications --------------------------------

_APP_JSON = {
    "fqtk": {"version": "0.4.0", "url": ["https://github.com/fulcrumgenomics/fqtk/"]},
    "seqkit": {"version": "2.14.0", "url": ["https://github.com/shenwei356/seqkit/"]},
    "poetry": {"version": "2.5.1"},
    "mold": {"removed": True, "url": ["https://github.com/rui314/mold/"]},
    "bash-language-server": {
        "version": "5.8.1",
        "url": ["https://github.com/bash-lsp/bash-language-server/"],
    },
    "htslib": {"version": "1.24", "url": ["https://github.com/samtools/samtools/"]},
    "samtools": {"version": "1.24", "url": ["https://github.com/samtools/samtools/"]},
}

_NOTIFICATIONS = [
    {"repo": "fulcrumgenomics/fqtk", "title": "v0.4.1", "url": "u1"},
    {"repo": "shenwei356/seqkit", "title": "SeqKit v2.14.0", "url": "u2"},
    {"repo": "python-poetry/poetry", "title": "2.5.1", "url": "u3"},
    {"repo": "some-org/untracked-repo", "title": "v1.0.0", "url": "u4"},
    {"repo": "rui314/mold", "title": "mold 2.42.1", "url": "u5"},
    {"repo": "bash-lsp/bash-language-server", "title": "server-5.8.1", "url": "u6"},
    {"repo": "bash-lsp/bash-language-server", "title": "vscode-client-1.43.2", "url": "u7"},
    {"repo": "pycqa/isort", "title": "9.0.0b5", "url": "u8"},
    {"repo": "samtools/samtools", "title": "1.24", "url": "u9"},
]

_TAG_DATA = {
    "u1": {"tag_name": "v0.4.1", "prerelease": False},
    "u2": {"tag_name": "v2.14.0", "prerelease": False},
    "u3": {"tag_name": "2.5.1", "prerelease": False},
    "u4": {"tag_name": "v1.0.0", "prerelease": False},
    "u5": {"tag_name": "mold 2.42.1", "prerelease": False},
    "u6": {"tag_name": "server-5.8.1", "prerelease": False},
    "u7": {"tag_name": "vscode-client-1.43.2", "prerelease": False},
    # Not flagged as a prerelease by GitHub itself; must be caught by the
    # bare-a/b-between-digits heuristic instead.
    "u8": {"tag_name": "9.0.0b5", "prerelease": False},
    "u9": {"tag_name": "1.24", "prerelease": False},
}


@pytest.fixture
def _mock_http_get_json(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(
        "koopa.notifications._http_get_json",
        lambda url, **_kwargs: _TAG_DATA[url],
    )


def _result_by_name(results: list[VersionCheckResult], name: str) -> VersionCheckResult:
    matches = [r for r in results if r.name == name]
    assert len(matches) == 1, f"expected exactly one result for '{name}', got {len(matches)}"
    return matches[0]


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_outdated_app() -> None:
    """Test that a newer release tag than the pinned version is outdated."""
    results, _untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    result = _result_by_name(results, "fqtk")
    assert result.current_version == "0.4.0"
    assert result.latest_version == "0.4.1"
    assert result.is_outdated


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_current_app() -> None:
    """Test that a release tag equal to the pinned version is up to date."""
    results, _untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    result = _result_by_name(results, "seqkit")
    assert result.current_version == "2.14.0"
    assert result.latest_version == "2.14.0"
    assert not result.is_outdated


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_name_fallback() -> None:
    """Test that an app with no GitHub url is matched by bare repo name."""
    results, _untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    result = _result_by_name(results, "poetry")
    assert result.current_version == "2.5.1"
    assert result.latest_version == "2.5.1"


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_untracked_repo() -> None:
    """Test that a repo with no matching app.json entry is reported as untracked."""
    _results, untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    assert untracked == {"some-org/untracked-repo": "v1.0.0"}


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_removed_tombstone() -> None:
    """Test that a repo matching a 'removed' tombstone is reported separately.

    Also exercises the repo-name-prefix stripping in the tag-to-version
    step: the tag ``"mold 2.42.1"`` has no separator between the bare repo
    name and the version number.
    """
    _results, _untracked, removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    assert removed == {"rui314/mold": "mold 2.42.1"}


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_drops_prerelease() -> None:
    """Test that a beta tag is dropped, not reported as an untracked repo."""
    _results, untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    assert "pycqa/isort" not in untracked


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_monorepo_prefix() -> None:
    """Test that the higher of two differently-prefixed monorepo tags wins."""
    results, _untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    result = _result_by_name(results, "bash-language-server")
    assert result.latest_version == "5.8.1"


@pytest.mark.usefixtures("_mock_http_get_json")
def test_compare_release_notifications_key_collision() -> None:
    """Test that two keys sourced from the same repo resolve to the one named after it."""
    results, _untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    assert any(r.name == "samtools" for r in results)
    assert not any(r.name == "htslib" for r in results)


def test_compare_release_notifications_skips_unresolvable_release(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Test that one failed release lookup does not abort the whole report."""

    def fail_for_one_url(url: str, **_kwargs: object) -> dict[str, object]:
        if url == "u1":
            raise urllib.error.URLError("temporary failure")
        return _TAG_DATA[url]

    monkeypatch.setattr("koopa.notifications._http_get_json", fail_for_one_url)
    results, untracked, _removed = compare_release_notifications(_NOTIFICATIONS, _APP_JSON)
    assert not any(result.name == "fqtk" for result in results)
    assert "some-org/untracked-repo" in untracked


# -- fetch_release_notifications -------------------------------------------------


def test_fetch_release_notifications_parses_lines(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test that each stdout line is parsed as one notification."""
    lines = [
        {"repo": "fulcrumgenomics/fqtk", "title": "v0.4.1", "url": "u1"},
        {"repo": "shenwei356/seqkit", "title": "SeqKit v2.14.0", "url": "u2"},
    ]
    stdout = "\n".join(json.dumps(line) for line in lines) + "\n"

    def fake_run(cmd: list[str], **_: object) -> subprocess.CompletedProcess:
        assert cmd[0].endswith("gh")
        assert "api" in cmd
        assert "--paginate" in cmd
        return subprocess.CompletedProcess(cmd, 0, stdout=stdout, stderr="")

    monkeypatch.setattr("koopa.notifications.shutil.which", lambda _name: "/usr/bin/gh")
    with patch("koopa.notifications.subprocess.run", side_effect=fake_run):
        result = fetch_release_notifications()
    assert result == lines


def test_fetch_release_notifications_requires_gh(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test that a missing 'gh' binary raises FileNotFoundError."""
    monkeypatch.setattr("koopa.notifications.shutil.which", lambda _name: None)
    with pytest.raises(FileNotFoundError):
        fetch_release_notifications()
