"""Compare GitHub release notifications against koopa's app registry.

Supplements ``koopa develop check-app-versions``: instead of polling every
app's own upstream, this reads the release notifications GitHub already
collected for the authenticated user (``gh``) and joins them against
app.json by GitHub repository. This also surfaces two things
``check-app-versions`` cannot: upstream repos koopa does not track at all,
and repos still generating release notifications for an app koopa has
since marked ``removed``.

A release notification's ``subject.title`` is the release's free-text
*name*, not necessarily its tag: a maintainer can set a release name like
"fixes hom-ref/hom-alt counts" that carries no version number at all. The
tag is only available by following ``subject.url``, the API URL of the
release resource itself, so every notification costs one extra GitHub API
call to resolve reliably.
"""

import json
import re
import shutil
import ssl
import subprocess
import urllib.error

from koopa.version import sanitize_version
from koopa.version_check import (
    _SPECIAL_CASES,
    VersionCheckResult,
    _check_github,
    _extract_github_repo_from_urls,
    _http_get_json,
    _is_prerelease,
    _sanitize_github_tag,
    _version_key,
)

_VERSION_IN_TITLE_RE = re.compile(r"\d+(?:\.\d+)+")


def fetch_release_notifications() -> list[dict[str, str]]:
    """Fetch GitHub Release notifications for the authenticated ``gh`` user.

    Returns
    -------
    list[dict[str, str]]
        One item per notification, each with a ``repo`` key (``owner/name``),
        a ``title`` key (the release name, as GitHub reports it), and a
        ``url`` key (the API URL of the release resource, used to resolve
        the release's actual tag).
    """
    gh = shutil.which("gh")
    if gh is None:
        msg = "'gh' is required to fetch GitHub release notifications."
        raise FileNotFoundError(msg)
    result = subprocess.run(
        [
            gh,
            "api",
            "--paginate",
            "notifications?all=true&per_page=50",
            "--jq",
            '.[] | select(.subject.type == "Release") | '
            "{repo: .repository.full_name, title: .subject.title, url: .subject.url}",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return [json.loads(line) for line in result.stdout.splitlines() if line.strip()]


def _resolve_release_tag(url: str) -> tuple[str, bool] | None:
    """Resolve a release notification's authoritative tag and prerelease flag.

    Parameters
    ----------
    url : str
        API URL of the release resource (a notification's ``subject.url``).

    Returns
    -------
    tuple[str, bool] | None
        ``(tag_name, prerelease)``, or None if the release resource could
        not be fetched (for example, it was deleted after notifying).
    """
    try:
        data = _http_get_json(url, github=True)
    except (
        ssl.SSLError,
        ConnectionResetError,
        TimeoutError,
        urllib.error.HTTPError,
        urllib.error.URLError,
    ):
        return None
    tag = data.get("tag_name")
    if not tag:
        return None
    return tag, bool(data.get("prerelease", False))


def _github_repo_for_app(name: str, info: dict) -> str | None:
    """Return the lowercase 'owner/repo' GitHub source of an app.json entry.

    Parameters
    ----------
    name : str
        App.json key.
    info : dict
        App.json entry for `name`.

    Returns
    -------
    str | None
        Lowercase ``owner/repo``, or None if the entry has no GitHub
        source.
    """
    repo = _extract_github_repo_from_urls(info.get("url", []))
    if repo:
        return repo.lower()
    spec = _SPECIAL_CASES.get(name)
    if spec is not None and spec.check_fn is _check_github:
        owner, repo_name = spec.args
        return f"{owner}/{repo_name}".lower()
    return None


def _primary_repo_to_keys(app_json: dict) -> dict[str, list[str]]:
    """Map each lowercase 'owner/repo' to the app.json keys sourced from it.

    Parameters
    ----------
    app_json : dict
        Full app.json registry.

    Returns
    -------
    dict[str, list[str]]
        Lowercase ``owner/repo`` mapped to the app.json keys sourced from
        it (normally one; more than one is a collision, see `_pick_key`).
    """
    repo_to_keys: dict[str, list[str]] = {}
    for name, info in app_json.items():
        if not isinstance(info, dict) or info.get("alias_of"):
            continue
        repo = _github_repo_for_app(name, info)
        if repo:
            repo_to_keys.setdefault(repo, []).append(name)
    return repo_to_keys


def _pick_key(repo: str, keys: list[str]) -> str:
    """Resolve a repo-to-multiple-keys collision: prefer the key named after it.

    Parameters
    ----------
    repo : str
        Lowercase ``owner/repo``.
    keys : list[str]
        App.json keys that all resolve to `repo` (more than one).

    Returns
    -------
    str
        The key equal to the repo's bare name, if any; otherwise the
        alphabetically first key.
    """
    bare_name = repo.rsplit("/", 1)[-1]
    for key in keys:
        if key == bare_name:
            return key
    return sorted(keys)[0]


def _tag_to_version(tag: str, bare_repo_name: str) -> str | None:
    """Extract a version number from a release tag, or None if it has none.

    Parameters
    ----------
    tag : str
        Release tag, e.g. ``"v1.2.3"`` or ``"server-5.8.1"``.
    bare_repo_name : str
        Bare repository name (no ``owner/``), used to strip a repo-name
        prefix such as ``seqkit`` from a tag like ``"SeqKit v2.14.0"``.

    Returns
    -------
    str | None
        The version number, or None if the tag has no digits at all.
    """
    candidate = _sanitize_github_tag(tag, bare_repo_name)
    if candidate[:1].isdigit():
        return candidate
    match = _VERSION_IN_TITLE_RE.search(tag)
    return match.group(0) if match else None


def compare_release_notifications(
    notifications: list[dict[str, str]],
    app_json: dict,
) -> tuple[list[VersionCheckResult], dict[str, str], dict[str, str]]:
    """Join release notifications against app.json by GitHub repository.

    Parameters
    ----------
    notifications : list[dict[str, str]]
        Notifications as returned by `fetch_release_notifications`, each
        with a ``url`` key pointing at the release resource to resolve.
    app_json : dict
        Full app.json registry, as returned by `koopa.io.import_app_json`.

    Returns
    -------
    tuple[list[VersionCheckResult], dict[str, str], dict[str, str]]
        - Results for apps koopa tracks, one per repo, with ``source``
          ``"notifications"``.
        - Untracked repos: lowercase ``owner/repo`` mapped to the highest
          release tag seen for it.
        - Removed repos: same shape, for repos matched to a ``removed``
          app.json tombstone.
    """
    repo_to_keys = _primary_repo_to_keys(app_json)
    claimed_keys = {key for keys in repo_to_keys.values() for key in keys}

    best_by_repo: dict[str, tuple[tuple[int, ...], str, str]] = {}
    for note in notifications:
        repo = note["repo"].lower()
        bare_name = repo.rsplit("/", 1)[-1]
        resolved = _resolve_release_tag(note["url"])
        if resolved is None:
            continue
        tag, prerelease = resolved
        version = _tag_to_version(tag, bare_name)
        if version is None or prerelease or _is_prerelease(version):
            continue
        order = _version_key(sanitize_version(version))
        current = best_by_repo.get(repo)
        if current is None or order > current[0]:
            best_by_repo[repo] = (order, tag, version)

    results: list[VersionCheckResult] = []
    untracked: dict[str, str] = {}
    removed: dict[str, str] = {}
    for repo, (_, tag, version) in best_by_repo.items():
        keys = repo_to_keys.get(repo)
        if not keys:
            bare_name = repo.rsplit("/", 1)[-1]
            if bare_name in app_json and bare_name not in claimed_keys:
                keys = [bare_name]
        if not keys:
            untracked[repo] = tag
            continue
        key = _pick_key(repo, keys)
        info = app_json[key]
        if info.get("removed", False):
            removed[repo] = tag
            continue
        results.append(
            VersionCheckResult(
                name=key,
                current_version=info.get("version", ""),
                latest_version=version,
                source="notifications",
            )
        )
    return results, untracked, removed
