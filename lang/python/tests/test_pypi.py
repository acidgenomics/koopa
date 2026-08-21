"""Private PyPI index management unit tests."""

import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.pypi import (
    _check_no_artifact_collision,
    _cloudfront_distribution_id,
    _sha256_of_file,
    _tag_and_push_release,
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
        ["git", "-C", str(bare), "tag", "-l"],
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
