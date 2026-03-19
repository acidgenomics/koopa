"""App module unit tests."""

from unittest.mock import patch

from koopa.app import app_deps


def test_app_deps_coreutils_excludes_attr_on_macos() -> None:
    """Test that 'attr' is excluded from coreutils deps on macOS."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("coreutils")
    assert "attr" not in deps
