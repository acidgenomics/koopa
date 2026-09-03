"""Private PyPI index management unit tests."""

import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.pypi import (
    _check_no_artifact_collision,
    _cloudfront_distribution_id,
    _parse_package_version,
    _select_published_artifacts,
    _sha256_of_file,
    _tag_and_push_release,
    _version_sort_key,
    publish_pypi_only,
)

_GIT_ENV = ["-c", "user.name=Test", "-c", "user.email=test@example.com"]


def _init_repo_with_remote(tmp_path: Path, version: str = "1.2.3") -> Path:
    """Create a package dir with a bare 'origin' remote and one commit."""
    bare = tmp_path / "origin.git"
    subprocess.run(["git", "init", "--bare", "-q", str(bare)], check=True)

    pkg = tmp_path / "pkg"
    pkg.mkdir()
    subprocess.run(["git", *_GIT_ENV, "init", "-q", str(pkg)], check=True)
    subprocess.run(
        ["git", "-C", str(pkg), "remote", "add", "origin", str(bare)],
        check=True,
    )
    (pkg / "pyproject.toml").write_text(f'[project]\nname = "pkg"\nversion = "{version}"\n')
    subprocess.run(["git", "-C", str(pkg), "add", "pyproject.toml"], check=True)
    subprocess.run(
        ["git", *_GIT_ENV, "-C", str(pkg), "commit", "-q", "-m", "Initial commit."],
        check=True,
    )
    return pkg


def _remote_tags(bare: Path) -> list[str]:
    result = subprocess.run(
        ["git", f"--git-dir={bare}", "tag", "-l"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [line for line in result.stdout.splitlines() if line]


def test_cloudfront_distribution_id_returns_specific_value() -> None:
    """Test the site-specific env var is used, not a generic one."""
    values = {
        "AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON": "EPYTHON123",
        "AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456",
    }
    with patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")):
        assert _cloudfront_distribution_id() == "EPYTHON123"


def test_cloudfront_distribution_id_raises_when_specific_missing_even_if_generic_set() -> None:
    """Test it fails loudly instead of silently falling back to a generic ID.

    Regression test: a stale/unrelated AWS_CLOUDFRONT_DISTRIBUTION_ID on a
    machine that never had AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON configured
    used to silently invalidate the wrong CloudFront distribution, leaving
    python.acidgenomics.com serving a stale cached index with no error at
    all. See koopa CHANGELOG for the incident this fixes.
    """
    values = {"AWS_CLOUDFRONT_DISTRIBUTION_ID": "EGENERIC456"}
    with (
        patch("koopa.aws.dotenv_value", side_effect=lambda k: values.get(k, "")),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON"),
    ):
        _cloudfront_distribution_id()


def test_cloudfront_distribution_id_raises_when_both_missing() -> None:
    """Test it raises when nothing is set at all."""
    with (
        patch("koopa.aws.dotenv_value", return_value=""),
        pytest.raises(RuntimeError, match="AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON"),
    ):
        _cloudfront_distribution_id()


def test_tag_and_push_release_creates_and_pushes_tag(tmp_path: Path) -> None:
    """Test it creates a 'v{version}' tag and pushes it to origin.

    Regression test: acidgenomes 0.2.0 shipped to python.acidgenomics.com
    with no v0.2.0 tag ever created on GitHub, because nothing in the
    publish path tagged or pushed a release ref.
    """
    pkg = _init_repo_with_remote(tmp_path, version="1.2.3")
    _tag_and_push_release(pkg)

    local = subprocess.run(
        ["git", "-C", str(pkg), "tag", "-l"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    assert "v1.2.3" in local.splitlines()
    assert "v1.2.3" in _remote_tags(tmp_path / "origin.git")


def test_tag_and_push_release_is_idempotent(tmp_path: Path) -> None:
    """Test calling it twice (e.g. a re-run) does not raise."""
    pkg = _init_repo_with_remote(tmp_path, version="1.2.3")
    _tag_and_push_release(pkg)
    _tag_and_push_release(pkg)  # must not raise on an already-tagged, already-pushed release
    assert "v1.2.3" in _remote_tags(tmp_path / "origin.git")


def test_tag_and_push_release_pushes_a_preexisting_local_tag(tmp_path: Path) -> None:
    """Test a tag created by hand but never pushed still gets pushed."""
    pkg = _init_repo_with_remote(tmp_path, version="1.2.3")
    subprocess.run(
        ["git", *_GIT_ENV, "-C", str(pkg), "tag", "-a", "v1.2.3", "-m", "v1.2.3"],
        check=True,
    )
    assert "v1.2.3" not in _remote_tags(tmp_path / "origin.git")

    _tag_and_push_release(pkg)

    assert "v1.2.3" in _remote_tags(tmp_path / "origin.git")


def test_tag_and_push_release_skips_non_git_directory(tmp_path: Path) -> None:
    """Test a package_dir with no .git/ is skipped without raising."""
    pkg = tmp_path / "pkg"
    pkg.mkdir()
    (pkg / "pyproject.toml").write_text('[project]\nname = "pkg"\nversion = "1.2.3"\n')
    _tag_and_push_release(pkg)  # must not raise


def test_tag_and_push_release_raises_when_version_missing(tmp_path: Path) -> None:
    """Test a pyproject.toml with no [project] version raises loudly."""
    pkg = _init_repo_with_remote(tmp_path, version="1.2.3")
    (pkg / "pyproject.toml").write_text('[project]\nname = "pkg"\n')
    with pytest.raises(RuntimeError, match="version not found"):
        _tag_and_push_release(pkg)


def test_check_no_artifact_collision_allows_a_new_file(tmp_path: Path) -> None:
    """Test a filename not yet on the index is not a collision."""
    dist = tmp_path / "pkg-1.2.3-py3-none-any.whl"
    dist.write_bytes(b"wheel contents")
    with patch("koopa.pypi._s3_list_packages", return_value=[]):
        _check_no_artifact_collision([dist], str(tmp_path))  # must not raise


def test_check_no_artifact_collision_allows_identical_content(tmp_path: Path) -> None:
    """Test re-publishing byte-identical content is not a collision."""
    dist = tmp_path / "pkg-1.2.3-py3-none-any.whl"
    dist.write_bytes(b"wheel contents")
    same_sha256 = _sha256_of_file(str(dist))
    with (
        patch("koopa.pypi._s3_list_packages", return_value=[dist.name]),
        patch("koopa.pypi._sha256_of_s3_file", return_value=same_sha256),
    ):
        _check_no_artifact_collision([dist], str(tmp_path))  # must not raise


def test_check_no_artifact_collision_raises_on_differing_content(tmp_path: Path) -> None:
    """Test it refuses to silently overwrite a published file with different bytes.

    Regression test: acidgenomes 0.2.0 was rebuilt from an unmerged branch and
    published() silently overwrote the original 0.2.0 wheel/sdist on S3 with
    different content -- same version, same filename, no error, no new tag,
    no CHANGELOG entry to mark the change (2026-08).
    """
    dist = tmp_path / "pkg-1.2.3-py3-none-any.whl"
    dist.write_bytes(b"new wheel contents")
    with (
        patch("koopa.pypi._s3_list_packages", return_value=[dist.name]),
        patch("koopa.pypi._sha256_of_s3_file", return_value="0" * 64),
        pytest.raises(RuntimeError, match="already published with different content"),
    ):
        _check_no_artifact_collision([dist], str(tmp_path))


def test_parse_package_version_from_wheel() -> None:
    """Test version extraction from a wheel filename."""
    assert _parse_package_version("pipette-0.2.0-py3-none-any.whl") == "0.2.0"


def test_parse_package_version_from_sdist() -> None:
    """Test version extraction from an sdist filename."""
    assert _parse_package_version("pipette-0.2.0.tar.gz") == "0.2.0"


def test_parse_package_version_returns_none_for_unrecognized_file() -> None:
    """Test a non-package file yields no version."""
    assert _parse_package_version("README.md") is None


def test_version_sort_key_orders_numerically_not_lexicographically() -> None:
    """Test 0.10.0 sorts after 0.9.0 despite '1' < '9' as characters."""
    assert _version_sort_key("0.9.0") < _version_sort_key("0.10.0")


def test_select_published_artifacts_matches_wheel_and_sdist() -> None:
    """Test it returns only the wheel and sdist for the exact name and version.

    Covers the underscore filename form ('acidgenomics_acidplyr-...') against
    the hyphenated distribution name ('acidgenomics-acidplyr'), and confirms
    other packages and other versions of the same package are excluded.
    """
    filenames = [
        "acidgenomics_acidplyr-0.1.1-py3-none-any.whl",
        "acidgenomics_acidplyr-0.1.1.tar.gz",
        "acidplyr-0.1.0-py3-none-any.whl",
        "acidgenomics_goalie-0.2.1.tar.gz",
    ]
    assert _select_published_artifacts(filenames, "acidgenomics-acidplyr", "0.1.1") == [
        "acidgenomics_acidplyr-0.1.1-py3-none-any.whl",
        "acidgenomics_acidplyr-0.1.1.tar.gz",
    ]


def test_select_published_artifacts_returns_empty_when_no_match() -> None:
    """Test no match returns an empty list, not a raise."""
    filenames = ["acidgenomics_acidplyr-0.1.0-py3-none-any.whl"]
    assert _select_published_artifacts(filenames, "acidgenomics-acidplyr", "0.1.1") == []


def test_publish_pypi_only_raises_when_no_published_artifact(tmp_path: Path) -> None:
    """Test it refuses to run when the S3 half never published this version.

    A missing artifact means there is nothing to resume -- publish() (without
    --pypi-only) is the correct command instead.
    """
    pkg = tmp_path / "pkg"
    pkg.mkdir()
    (pkg / "pyproject.toml").write_text(
        '[project]\nname = "acidgenomics-acidplyr"\nversion = "0.1.1"\n'
    )
    with (
        patch("koopa.pypi._s3_list_packages", return_value=[]),
        pytest.raises(RuntimeError, match="No published wheel and sdist found"),
    ):
        publish_pypi_only(str(pkg))


def test_publish_pypi_only_raises_when_version_missing(tmp_path: Path) -> None:
    """Test a pyproject.toml with no [project] version raises loudly."""
    pkg = tmp_path / "pkg"
    pkg.mkdir()
    (pkg / "pyproject.toml").write_text('[project]\nname = "acidgenomics-acidplyr"\n')
    with pytest.raises(RuntimeError, match="name/version not found"):
        publish_pypi_only(str(pkg))


def test_reindex_landing_summary_picks_highest_version_wheel() -> None:
    """Test the landing page reads the Summary from the newest wheel, not the first.

    Regression test: reindex() picked the first ``.whl`` filename per package
    from a plain lexicographically sorted S3 listing, which is the *oldest*
    version, not the latest. After a package's second release, the landing
    page permanently showed the previous version's description -- reproduced
    live for pipette and goalie (2026-08).
    """
    whls = ["pipette-0.1.0-py3-none-any.whl", "pipette-0.2.0-py3-none-any.whl"]
    picked = max(whls, key=lambda f: _version_sort_key(_parse_package_version(f) or ""))
    assert picked == "pipette-0.2.0-py3-none-any.whl"
