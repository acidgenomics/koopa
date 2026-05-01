"""App module unit tests."""

from unittest.mock import patch

from koopa.app import app_deps


def test_app_deps_coreutils_excludes_attr_on_macos() -> None:
    """Test that 'attr' is excluded from coreutils deps on macOS."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("coreutils")
    assert "attr" not in deps


def test_app_deps_no_self_dependency_curl() -> None:
    """Test that curl does not appear in its own dependency list."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("curl")
    assert "curl" not in deps


def test_app_deps_no_self_dependency_cmake() -> None:
    """Test that cmake does not appear in its own dependency list."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("cmake")
    assert "cmake" not in deps


def test_app_deps_curl_includes_cmake() -> None:
    """Test that cmake is a transitive dependency of curl (via zstd)."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("curl")
    assert "cmake" in deps
