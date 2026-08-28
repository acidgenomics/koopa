"""R language helper function unit tests."""

from pathlib import Path
from unittest.mock import patch

from koopa.r import _r_build_source, r_check


def test_r_build_source_returns_built_tarball(tmp_path: Path) -> None:
    """Test R CMD build writes a source tarball used by R CMD check."""
    tarball = tmp_path / "pkg_1.0.0.tar.gz"

    def mock_run(args: list[str], **kwargs: object) -> None:
        assert args == ["R", "CMD", "build", "/pkg"]
        assert kwargs == {"cwd": tmp_path, "check": True}
        tarball.touch()

    with patch("koopa.r.subprocess.run", side_effect=mock_run):
        assert _r_build_source("/pkg", tmp_path) == tarball


def test_r_check_checks_built_source_archive() -> None:
    """Test direct source-directory checks are avoided."""
    tarball = Path("/tmp/pkg_1.0.0.tar.gz")
    with (
        patch("koopa.r._r_build_source", return_value=tarball) as mock_build,
        patch("koopa.r.subprocess.run") as mock_run,
    ):
        r_check("/pkg")

    mock_build.assert_called_once()
    args, kwargs = mock_run.call_args
    assert args[0] == ["R", "CMD", "check", "--as-cran", "--no-manual", str(tarball)]
    assert kwargs["check"] is True
