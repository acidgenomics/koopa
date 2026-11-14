"""Tests for local post-merge release publication."""

import hashlib
import json
import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa import release_publish
from koopa.prefix import koopa_prefix


def _fake_release_file(path: str) -> str:
    files = {
        "head:pyproject.toml": '[project]\nversion = "1.2.3"\n'
        '[tool.bumpver]\ncurrent_version = "v1.2.3"',
        "head:.claude-plugin/marketplace.json": '{"metadata": {"version": "1.2.3"}}',
        "head:CHANGELOG.md": "## koopa 1.2.3 (2026-11-14)\n\n- Release",
    }
    return files.get(path, '{"version": "1.2.3"}' if path.endswith(".json") else "")


def test_bootstrap_urls_match_script() -> None:
    """Extract the exact source URLs from the current bootstrap script."""
    root = Path(koopa_prefix())
    script = (root / "bootstrap.sh").read_text()
    urls = release_publish._bootstrap_urls(script, (root / ".python-version").read_text().strip())
    assert len(urls) == 7
    assert any("/src/openssl3/openssl-" in url for url in urls)
    assert any("/src/python3.14/Python-" in url for url in urls)
    assert all("$" not in url for url in urls)


@pytest.mark.parametrize("invocation", ["install_newdep", "install_newdep || return 1"])
def test_bootstrap_urls_reject_unknown_installer(invocation: str) -> None:
    """A new bootstrap dependency must not silently escape the mirror check."""
    root = Path(koopa_prefix())
    script = (
        (root / "bootstrap.sh")
        .read_text()
        .replace(
            "            install_libffi\n",
            f"            install_libffi\n            {invocation}\n",
        )
    )
    with pytest.raises(ValueError, match="Unrecognized bootstrap installer"):
        release_publish._bootstrap_urls(script, (root / ".python-version").read_text().strip())


def test_release_notes_use_only_requested_section() -> None:
    """Use the matching changelog body, not the next release's notes."""
    changelog = (
        "# Changelog\n\n## koopa 1.2.3 (2026-11-14)\n\n- New\n\n"
        "## koopa 1.2.2 (2026-01-01)\n\n- Old\n"
    )
    assert release_publish._notes(changelog, "v1.2.3") == "- New\n"
    with pytest.raises(ValueError, match="No changelog section"):
        release_publish._notes(changelog, "v2.0.0")


@pytest.mark.parametrize(
    ("stale_path", "message"),
    [
        ("install-release", "installer does not match"),
        ("_sources/apps.md.txt", "documentation is stale"),
        ("_sources/_generated/app-stack.md.txt", "documentation is stale"),
    ],
)
def test_verify_site_checks_archive_and_docs(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, stale_path: str, message: str
) -> None:
    """Require the public archive checksum and changed documentation to match."""
    (tmp_path / "docs").mkdir()
    (tmp_path / "docs" / "_generated").mkdir()
    (tmp_path / "docs" / "apps.md").write_text("new docs\n")
    (tmp_path / "docs" / "_generated" / "app-stack.md").write_text("app stack\n")
    (tmp_path / "install-release.sh").write_bytes(b"installer")
    archive = b"release archive"
    digest = hashlib.sha256(archive).hexdigest()
    urls = {
        f"{release_publish._SITE}/releases/latest": f"v1.2.3 {digest}\n".encode(),
        f"{release_publish._SITE}/releases/v1.2.3/koopa.tar.gz": archive,
        f"{release_publish._SITE}/install-release": b"installer",
        f"{release_publish._SITE}/": b"home",
        f"{release_publish._SITE}/_sources/apps.md.txt": b"new docs\n",
        f"{release_publish._SITE}/apps.html": b"html",
        f"{release_publish._SITE}/_sources/_generated/app-stack.md.txt": b"app stack\n",
        f"{release_publish._SITE}/_generated/app-stack.html": b"html",
    }
    monkeypatch.setattr(release_publish, "_read_url", urls.__getitem__)
    release_publish._verify_site("v1.2.3", tmp_path, ["docs/apps.md"])
    urls[f"{release_publish._SITE}/{stale_path}"] = b"stale"
    monkeypatch.setattr(release_publish.time, "sleep", lambda _: None)
    with pytest.raises(RuntimeError, match=message):
        release_publish._verify_site("v1.2.3", tmp_path, ["docs/apps.md"])


@pytest.mark.parametrize("conflict", ["dirty", "unmerged", "wrong_tag", "remote_tag"])
def test_release_preflight_stops_before_mutation(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, conflict: str
) -> None:
    """Reject unsafe release state before running checks, tagging, or publishing."""
    pr = {
        "state": "OPEN" if conflict == "unmerged" else "MERGED",
        "title": "v9.9.9" if conflict == "wrong_tag" else "v1.2.3",
        "baseRefName": "main",
        "headRefName": "develop",
        "headRefOid": "head",
        "mergeCommit": {"oid": "merge"},
    }

    def fake_git(_root: Path, *args: str) -> str:
        if args[0] == "rev-list":
            return "merge base head"
        if args[0] == "status":
            return " M docs/apps.md" if conflict == "dirty" else ""
        if args[:2] == ("rev-parse", "refs/remotes/origin/main"):
            return "main"
        if args[0] == "rev-parse":
            return "tree"
        if args[0] == "show":
            return _fake_release_file(args[1])
        return ""

    def fake_gh(_root: Path, *args: str) -> str:
        if args[0] == "pr":
            return json.dumps(pr)
        return json.dumps({"object": {"sha": "main"}})

    monkeypatch.setattr(release_publish, "_git", fake_git)
    monkeypatch.setattr(release_publish, "_gh", fake_gh)
    monkeypatch.setattr(release_publish, "_is_ancestor", lambda *_: True)
    monkeypatch.setattr(release_publish, "_releases", lambda _: [])
    monkeypatch.setattr(release_publish, "_remote_tag", lambda *_: "wrong")
    with (
        patch.object(subprocess, "run") as run,
        pytest.raises((RuntimeError, ValueError)),
    ):
        release_publish._finish_release(tmp_path, "v1.2.3", 42)
    run.assert_not_called()


def test_release_rejects_multiple_previous_releases() -> None:
    """Never guess which previous release should be deleted."""
    releases = [
        {"tagName": tag, "isDraft": False, "isPrerelease": False} for tag in ("v1.0.0", "v1.1.0")
    ]
    with pytest.raises(ValueError, match="Multiple prior"):
        release_publish._verify_release_list(releases, "v1.2.3")


@pytest.mark.parametrize("fail_docs", ["none", "dryrun", "publish"])
@pytest.mark.parametrize("missing_source", [False, True])
def test_complete_release_orders_publication_and_preserves_previous_tag(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, fail_docs: str, missing_source: bool
) -> None:
    """Create the new release before removing the old one; stop on publish failure."""
    state = {"tag": False, "local_tag": False, "current": False, "previous": True}
    calls: list[str] = []
    pr = {
        "state": "MERGED",
        "title": "v1.2.3",
        "baseRefName": "main",
        "headRefName": "develop",
        "headRefOid": "head",
        "mergeCommit": {"oid": "merge"},
    }

    def fake_git(_root: Path, *args: str) -> str:
        if args[0] == "rev-list":
            return "merge base head"
        if args[:2] == ("rev-parse", "refs/remotes/origin/main"):
            return "main"
        if args[0] == "rev-parse":
            return "head" if args[1].startswith("refs/tags/") else "tree"
        if args[0] == "show":
            return _fake_release_file(args[1])
        if args[:2] == ("tag", "--list"):
            return "v1.2.3" if state["local_tag"] else ""
        return ""

    def fake_gh(_root: Path, *args: str) -> str:
        if args[0] == "pr":
            return json.dumps(pr)
        if args[0] == "api":
            return json.dumps({"object": {"sha": "main"}})
        return json.dumps(
            {
                "name": "v1.2.3",
                "tagName": "v1.2.3",
                "body": "- Release",
                "isDraft": False,
                "isPrerelease": False,
            }
        )

    def fake_releases(_root: Path) -> list[dict]:
        releases = []
        if state["previous"]:
            releases.append(
                {
                    "tagName": "v1.2.2",
                    "isDraft": False,
                    "isPrerelease": False,
                    "isLatest": not state["current"],
                }
            )
        if state["current"]:
            releases.append(
                {
                    "tagName": "v1.2.3",
                    "isDraft": False,
                    "isPrerelease": False,
                    "isLatest": True,
                }
            )
        return releases

    def fake_run(args: list[str], **_kwargs: object) -> None:
        calls.append(" ".join(args[:3]))
        if (
            args[1:3] == ["develop", "audit-src-mirror"]
            and missing_source
            and sum(call.endswith("develop audit-src-mirror") for call in calls) == 1
        ):
            raise subprocess.CalledProcessError(1, args)
        if args[:2] == ["git", "tag"]:
            state["local_tag"] = True
        elif args[:2] == ["git", "push"]:
            state["tag"] = True
        elif args[:3] == ["gh", "release", "create"]:
            state["current"] = True
        elif args[:3] == ["gh", "release", "delete"]:
            state["previous"] = False

    def fake_docs(*, dryrun: bool = False) -> None:
        calls.append("docs-dry" if dryrun else "docs")
        if (fail_docs == "dryrun" and dryrun) or (fail_docs == "publish" and not dryrun):
            raise RuntimeError("docs failed")

    monkeypatch.setattr(release_publish, "_git", fake_git)
    monkeypatch.setattr(release_publish, "_gh", fake_gh)
    monkeypatch.setattr(release_publish, "_is_ancestor", lambda *_: True)
    monkeypatch.setattr(release_publish, "_releases", fake_releases)
    monkeypatch.setattr(
        release_publish,
        "_remote_tag",
        lambda _root, tag: "old" if tag == "v1.2.2" else ("head" if state["tag"] else None),
    )
    monkeypatch.setattr(release_publish, "_bootstrap_urls", lambda *_: [])
    monkeypatch.setattr(release_publish, "_verify_site", lambda *_: calls.append("verify"))
    monkeypatch.setattr(subprocess, "run", fake_run)
    monkeypatch.setattr(
        "koopa.release.publish_release", lambda *_args, **_kwargs: calls.append("archive")
    )
    monkeypatch.setattr("koopa.site.publish_docs", fake_docs)
    monkeypatch.setattr("koopa.site._cloudfront_distribution_id", lambda: "distribution")
    if fail_docs != "none":
        with pytest.raises(RuntimeError, match="docs failed"):
            release_publish._finish_release(tmp_path, "v1.2.3", 42)
        assert state["previous"]
        assert not state["current"]
        if fail_docs == "dryrun":
            assert not state["tag"]
            assert not state["local_tag"]
            assert "archive" not in calls
        return
    release_publish._finish_release(tmp_path, "v1.2.3", 42)
    assert calls.index("archive") < calls.index("docs") < calls.index("verify")
    if missing_source:
        assert any(call.endswith("develop mirror-src") for call in calls)
    assert (
        calls.index("verify") < calls.index("gh release create") < calls.index("gh release delete")
    )
    assert not state["previous"]
    assert state["current"]
    assert release_publish._remote_tag(tmp_path, "v1.2.2") == "old"
    calls.clear()
    release_publish._finish_release(tmp_path, "v1.2.3", 42)
    assert "gh release create" not in calls
    assert "gh release delete" not in calls
    assert not any(call.startswith("git push") for call in calls)
