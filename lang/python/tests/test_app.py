"""App module unit tests."""

from unittest.mock import patch

from koopa.app import app_deps, is_cpu_bound_app


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


def test_app_deps_libarchive_includes_cmake() -> None:
    """Test that cmake is a transitive dependency of libarchive (via zstd)."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("libarchive")
    assert "cmake" in deps


# -- is_cpu_bound_app classifier tests ----------------------------------------


def _json(installer: str = "", src_url: str = "") -> dict:
    entry: dict = {}
    if installer:
        entry["installer"] = installer
    if src_url:
        entry["src_url"] = src_url
    return entry


def test_is_cpu_bound_conda_package() -> None:
    """Conda-package installer is IO-bound."""
    assert is_cpu_bound_app("aws-cli", {"aws-cli": _json("conda-package")}) is False


def test_is_cpu_bound_python_package() -> None:
    """Python-package installer is IO-bound."""
    assert is_cpu_bound_app("tqdm", {"tqdm": _json("python-package")}) is False


def test_is_cpu_bound_node_package() -> None:
    """Node-package installer is IO-bound."""
    assert is_cpu_bound_app("pyright", {"pyright": _json("node-package")}) is False


def test_is_cpu_bound_gnu_app() -> None:
    """GNU-app installer is CPU-bound."""
    assert is_cpu_bound_app("coreutils", {"coreutils": _json("gnu-app")}) is True


def test_is_cpu_bound_rust_package() -> None:
    """Rust-package installer is CPU-bound."""
    assert is_cpu_bound_app("ripgrep", {"ripgrep": _json("rust-package")}) is True


def test_is_cpu_bound_openssl_installer() -> None:
    """OpenSSL installer is CPU-bound."""
    assert is_cpu_bound_app("openssl3", {"openssl3": _json("openssl")}) is True


def test_is_cpu_bound_src_url() -> None:
    """Apps with a src_url (source builds) are CPU-bound."""
    assert (
        is_cpu_bound_app("myapp", {"myapp": _json(src_url="https://example.com/myapp.tar.gz")})
        is True
    )


def test_is_cpu_bound_download_only_allowlist_go() -> None:
    """Go is in the download-only allowlist and is IO-bound."""
    assert is_cpu_bound_app("go", {"go": _json()}) is False


def test_is_cpu_bound_download_only_allowlist_rust() -> None:
    """Rust is in the download-only allowlist and is IO-bound."""
    assert is_cpu_bound_app("rust", {"rust": _json()}) is False


def test_is_cpu_bound_ambiguous_defaults_cpu() -> None:
    """Unknown apps with no installer or src_url default to CPU-bound."""
    assert is_cpu_bound_app("unknown-custom-app", {"unknown-custom-app": _json()}) is True


def test_is_cpu_bound_missing_entry() -> None:
    """Apps absent from app.json are not classified as CPU-bound."""
    assert is_cpu_bound_app("nonexistent", {}) is False
