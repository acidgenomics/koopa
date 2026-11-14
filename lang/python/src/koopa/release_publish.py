"""Publish a merged koopa release from the local release checkout."""

import fcntl
import hashlib
import json
import re
import subprocess
import tempfile
import time
import tomllib
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

from koopa.release import _version

_REPO = "acidgenomics/koopa"
_SITE = "https://koopa.acidgenomics.com"
_BOOTSTRAP_NAMES = {
    "perl": "perl",
    "openssl": "openssl3",
    "zlib": "zlib",
    "bzip2": "bzip2",
    "xz": "xz",
    "libffi": "libffi",
    "python": "python",
}


def _run(args: list[str], root: Path) -> str:
    try:
        result = subprocess.run(args, cwd=root, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as exc:
        raise RuntimeError(f"{' '.join(args)} failed: {exc.stderr.strip()}") from exc
    return result.stdout.strip()


def _git(root: Path, *args: str) -> str:
    return _run(["git", *args], root)


def _gh(root: Path, *args: str) -> str:
    return _run(["gh", *args], root)


def _is_ancestor(root: Path, commit: str, ref: str) -> bool:
    try:
        subprocess.run(
            ["git", "merge-base", "--is-ancestor", commit, ref],
            cwd=root,
            capture_output=True,
            check=True,
        )
    except subprocess.CalledProcessError as exc:
        if exc.returncode == 1:
            return False
        raise
    return True


def _notes(changelog: str, tag: str) -> str:
    heading = re.compile(rf"^## koopa {re.escape(tag[1:])} \(\d{{4}}-\d{{2}}-\d{{2}}\)$", re.M)
    match = heading.search(changelog)
    if match is None:
        raise ValueError(f"No changelog section for {tag}.")
    remaining = changelog[match.end() :]
    next_heading = re.search(r"^## ", remaining, re.M)
    notes = remaining[: next_heading.start()] if next_heading else remaining
    if not notes.strip():
        raise ValueError(f"Empty changelog section for {tag}.")
    return notes.strip() + "\n"


def _bootstrap_urls(script: str, python_version: str) -> list[str]:
    main = re.search(r"(?ms)^main\(\) \{\n(.*?)^\}", script)
    if main is None:
        raise ValueError("Cannot locate bootstrap main function.")
    called = set(re.findall(r"\binstall_([a-z0-9_]+)\b", main.group(1)))
    called.discard("python_uv")
    if called != set(_BOOTSTRAP_NAMES):
        raise ValueError(f"Unrecognized bootstrap installer set: {sorted(called)}")
    if not re.fullmatch(r"\d+\.\d+", python_version):
        raise ValueError("Invalid bootstrap .python-version.")
    urls = []
    for function, source_name in _BOOTSTRAP_NAMES.items():
        body = re.search(rf"(?ms)^install_{function}\(\) \{{\n(.*?)^\}}", script)
        if body is None:
            raise ValueError(f"Missing bootstrap installer: {function}.")
        version = re.search(r"^\s+__kvar_version='([^']+)'$", body.group(1), re.M)
        filename = re.search(r'^\s+__kvar_filename="([^"]+)"$', body.group(1), re.M)
        mirror = re.search(r'"(https://koopa\.acidgenomics\.com/src/[^"]+)"', body.group(1))
        if version is None or filename is None or mirror is None:
            raise ValueError(f"Unrecognized bootstrap source format: {function}.")
        name = f"python{python_version}" if source_name == "python" else source_name
        filename_value = filename.group(1).replace("${__kvar_version}", version.group(1))
        url = mirror.group(1).replace("${__kvar_mirror_name}", name)
        url = url.replace("${__kvar_filename}", filename_value)
        if "$" in url or not url.startswith(f"{_SITE}/src/{name}/"):
            raise ValueError(f"Unrecognized bootstrap URL: {url}")
        urls.append(url)
    return urls


def _read_url(url: str) -> bytes:
    with urllib.request.urlopen(url, timeout=60) as response:
        return response.read()


def _releases(root: Path) -> list[dict[str, Any]]:
    return json.loads(
        _gh(
            root,
            "release",
            "list",
            "--repo",
            _REPO,
            "--limit",
            "1000",
            "--json",
            "tagName,name,isDraft,isPrerelease,isLatest",
        )
    )


def _verify_release_list(releases: list[dict[str, Any]], tag: str) -> str | None:
    stable = [item for item in releases if not item["isDraft"] and not item["isPrerelease"]]
    others = [item for item in stable if item["tagName"] != tag]
    if len(others) > 1:
        raise ValueError("Multiple prior stable GitHub releases exist; inspect them manually.")
    for item in stable:
        if _version(item["tagName"]) > _version(tag):
            raise ValueError("A newer GitHub release already exists.")
    return others[0]["tagName"] if others else None


def _verify_release_metadata(root: Path, tag: str, notes: str) -> None:
    release = json.loads(
        _gh(
            root,
            "release",
            "view",
            tag,
            "--repo",
            _REPO,
            "--json",
            "name,tagName,body,isDraft,isPrerelease",
        )
    )
    if (
        release["name"] != tag
        or release["tagName"] != tag
        or release["body"].strip() != notes.strip()
        or release["isDraft"]
        or release["isPrerelease"]
    ):
        raise RuntimeError("GitHub release metadata differs from the changelog.")


def _remote_tag(root: Path, tag: str) -> str | None:
    ref = f"refs/tags/{tag}"
    output = _git(root, "ls-remote", "--tags", "origin", ref, f"{ref}^{{}}")
    refs = dict(line.split("\t", 1)[::-1] for line in output.splitlines())
    return refs.get(f"{ref}^{{}}", refs.get(ref))


def _verify_site(tag: str, root: Path, changed_docs: list[str]) -> None:
    for attempt in range(12):
        try:
            manifest = _read_url(f"{_SITE}/releases/latest").decode().split()
            if len(manifest) != 2 or manifest[0] != tag:
                raise RuntimeError("Public latest manifest does not name the release.")
            archive = _read_url(f"{_SITE}/releases/{tag}/koopa.tar.gz")
            if hashlib.sha256(archive).hexdigest() != manifest[1]:
                raise RuntimeError(
                    "Public release archive checksum does not match latest manifest."
                )
            if _read_url(f"{_SITE}/install-release") != (root / "install-release.sh").read_bytes():
                raise RuntimeError("Public release installer does not match the release.")
            if not _read_url(f"{_SITE}/"):
                raise RuntimeError("Public documentation homepage is empty.")
            for path in sorted({*changed_docs, "docs/_generated/app-stack.md"}):
                relative = path.removeprefix("docs/")
                url_path = urllib.parse.quote(relative)
                if _read_url(f"{_SITE}/_sources/{url_path}.txt") != (root / path).read_bytes():
                    raise RuntimeError(f"Public documentation is stale: {path}")
                _read_url(f"{_SITE}/{urllib.parse.quote(relative.removesuffix('.md'))}.html")
            return
        except (OSError, RuntimeError) as exc:
            if attempt == 11:
                raise RuntimeError(f"Public release verification failed: {exc}") from exc
            time.sleep(5)


def _publish_github_release(
    root: Path, tag: str, notes: str, previous: str | None, previous_commit: str | None, commit: str
) -> None:
    releases = _releases(root)
    _verify_release_list(releases, tag)
    current = next((item for item in releases if item["tagName"] == tag), None)
    if current is None:
        with tempfile.TemporaryDirectory() as tmp:
            notes_path = Path(tmp) / "notes.md"
            notes_path.write_text(notes)
            subprocess.run(
                [
                    "gh",
                    "release",
                    "create",
                    tag,
                    "--repo",
                    _REPO,
                    "--verify-tag",
                    "--title",
                    tag,
                    "--notes-file",
                    str(notes_path),
                ],
                cwd=root,
                check=True,
            )
    _verify_release_metadata(root, tag, notes)
    releases = _releases(root)
    if not any(item["tagName"] == tag and item["isLatest"] for item in releases):
        raise RuntimeError("New GitHub release is not marked latest.")
    if previous:
        if _verify_release_list(releases, tag) != previous:
            raise RuntimeError("GitHub releases changed during publication.")
        if _remote_tag(root, previous) != previous_commit:
            raise RuntimeError("Previous GitHub release tag changed during publication.")
        subprocess.run(
            ["gh", "release", "delete", previous, "--repo", _REPO, "--yes"],
            cwd=root,
            check=True,
        )
    final_releases = _releases(root)
    if (
        _verify_release_list(final_releases, tag) is not None
        or not any(item["tagName"] == tag and item["isLatest"] for item in final_releases)
        or _remote_tag(root, tag) != commit
        or (previous and _remote_tag(root, previous) != previous_commit)
    ):
        raise RuntimeError("Final release verification failed.")


def finish_release(tag: str, pr_number: int) -> None:
    """Publish a merged koopa release using local GitHub and AWS credentials.

    Parameters
    ----------
    tag : str
        Stable version tag matching the release pull request title.
    pr_number : int
        Merged develop-to-main release pull request number.
    """
    from koopa.prefix import koopa_prefix
    from koopa.xdg import xdg_cache_home

    _version(tag)
    if pr_number <= 0:
        raise ValueError("Pull request number must be positive.")
    root = Path(koopa_prefix())
    lock_dir = Path(xdg_cache_home()) / "koopa"
    lock_dir.mkdir(parents=True, exist_ok=True)
    with (lock_dir / "publish-release.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        _finish_release(root, tag, pr_number)


def _finish_release(root: Path, tag: str, pr_number: int) -> None:
    from koopa.release import publish_release
    from koopa.site import _cloudfront_distribution_id, publish_docs

    if _git(root, "status", "--porcelain", "--untracked-files=normal"):
        raise RuntimeError("Release checkout must be clean.")
    _git(root, "fetch", "origin")
    pr = json.loads(
        _gh(
            root,
            "pr",
            "view",
            str(pr_number),
            "--repo",
            _REPO,
            "--json",
            "state,title,baseRefName,headRefName,mergeCommit",
        )
    )
    if pr["title"] != tag:
        raise ValueError("PR title does not match the requested tag.")
    if pr["state"] != "MERGED" or pr["baseRefName"] != "main" or pr["headRefName"] != "develop":
        raise ValueError("Expected a merged develop-to-main release PR.")
    main = _git(root, "rev-parse", "refs/remotes/origin/main")
    github_main = json.loads(_gh(root, "api", f"repos/{_REPO}/git/ref/heads/main"))["object"]["sha"]
    if main != github_main:
        raise RuntimeError("origin/main does not match GitHub main.")
    merge = pr["mergeCommit"]["oid"]
    if not _is_ancestor(root, merge, main):
        raise RuntimeError("PR merge commit is not in origin/main.")
    parents = _git(root, "rev-list", "--parents", "-n", "1", merge).split()
    if not parents or parents[0] != merge or len(parents) > 3:
        raise RuntimeError("Unexpected release merge parents.")
    commit = merge
    if len(parents) == 3 and _git(root, "rev-parse", f"{parents[2]}^{{tree}}") == _git(
        root, "rev-parse", f"{merge}^{{tree}}"
    ):
        commit = parents[2]
    if _git(root, "rev-parse", f"{commit}^{{tree}}") != _git(root, "rev-parse", "HEAD^{tree}"):
        raise RuntimeError("Checkout tree does not match the merged release.")
    if _git(root, "rev-parse", f"{commit}^{{tree}}") != _git(root, "rev-parse", f"{main}^{{tree}}"):
        raise RuntimeError("GitHub main has advanced beyond the release tree.")
    project = tomllib.loads(_git(root, "show", f"{commit}:pyproject.toml"))
    if (
        project["project"]["version"] != tag[1:]
        or project["tool"]["bumpver"]["current_version"] != tag
    ):
        raise ValueError("PR title does not match the release version.")
    for path in (
        ".claude-plugin/marketplace.json",
        "plugins/koopa/plugin.json",
        "plugins/koopa/.claude-plugin/plugin.json",
        "plugins/koopa/gemini-extension.json",
    ):
        manifest = json.loads(_git(root, "show", f"{commit}:{path}"))
        version = (
            manifest["metadata"]["version"]
            if path.startswith(".claude-plugin/")
            else manifest["version"]
        )
        if version != tag[1:]:
            raise ValueError(f"Release version does not match {path}.")
    notes = _notes(_git(root, "show", f"{commit}:CHANGELOG.md"), tag)
    releases = _releases(root)
    previous = _verify_release_list(releases, tag)
    if any(item["tagName"] == tag for item in releases):
        _verify_release_metadata(root, tag, notes)
    previous_commit = _remote_tag(root, previous) if previous else None
    if previous and previous_commit is None:
        raise RuntimeError("The previous GitHub release has no remote tag.")
    changed_docs = [
        path
        for path in _git(
            root, "diff", "--name-only", f"{merge}^1", merge, "--", "docs"
        ).splitlines()
        if path.endswith(".md")
        and (root / path).is_file()
        and not any(part.startswith("_") for part in Path(path).parts[1:])
    ]
    remote_tag = _remote_tag(root, tag)
    if remote_tag and remote_tag != commit:
        raise RuntimeError("Remote release tag points to a different commit.")
    local_tags = _git(root, "tag", "--list", tag).splitlines()
    if local_tags and _git(root, "rev-parse", f"refs/tags/{tag}^{{commit}}") != commit:
        raise RuntimeError("Local release tag points to a different commit.")

    koopa = str(root / "bin" / "koopa")
    print("Checking the release and documentation before tagging.", flush=True)
    subprocess.run([koopa, "develop", "check"], cwd=root, check=True)
    _cloudfront_distribution_id()
    publish_docs(dryrun=True)
    try:
        subprocess.run([koopa, "develop", "audit-src-mirror"], cwd=root, check=True)
    except subprocess.CalledProcessError:
        subprocess.run([koopa, "develop", "mirror-src"], cwd=root, check=True)
        subprocess.run([koopa, "develop", "audit-src-mirror"], cwd=root, check=True)
    script = _git(root, "show", f"{commit}:bootstrap.sh")
    python_version = _git(root, "show", f"{commit}:.python-version")
    for url in _bootstrap_urls(script, python_version):
        request = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(request, timeout=60):
            pass
    if _git(root, "status", "--porcelain", "--untracked-files=normal"):
        raise RuntimeError("Release checks changed the checkout.")
    github_main = json.loads(_gh(root, "api", f"repos/{_REPO}/git/ref/heads/main"))["object"]["sha"]
    if github_main != main or _verify_release_list(_releases(root), tag) != previous:
        raise RuntimeError("GitHub main or releases changed during release checks.")
    print(f"Publishing tag and stable archive for {tag}.", flush=True)
    if not local_tags:
        subprocess.run(["git", "tag", tag, commit], cwd=root, check=True)
    if remote_tag is None:
        subprocess.run(["git", "push", "origin", f"refs/tags/{tag}"], cwd=root, check=True)
    if _remote_tag(root, tag) != commit:
        raise RuntimeError("Remote tag verification failed.")
    publish_release(tag, main_ref="refs/remotes/origin/main")
    print("Publishing and verifying the documentation website.", flush=True)
    publish_docs()
    _verify_site(tag, root, changed_docs)
    print("Publishing and verifying the GitHub release.", flush=True)
    _publish_github_release(root, tag, notes, previous, previous_commit, commit)
    print(f"Published {tag} successfully.", flush=True)
