"""Application installation functions.

Converted from Bash functions:
- install-app.sh: Install application in a versioned directory structure.
- install-app-subshell.sh: Install an application in a hardened subshell.
- install-app-from-binary-package.sh: Install from pre-built binary package.
"""

from __future__ import annotations

import contextlib
import json
import os
import platform
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from koopa.archive import extract
from koopa.download import download
from koopa.system import is_admin, is_linux, is_macos, is_owner

# -- Data classes -------------------------------------------------------------


@dataclass
class InstallConfig:
    """Configuration for application installation."""

    name: str
    version: str = ""
    version_key: str = ""
    prefix: str = ""
    installer: str = ""
    platform: str = "common"
    mode: str = "shared"
    # Boolean flags.
    auto_prefix: bool = False
    binary: bool = False
    bootstrap: bool = False
    copy_log_files: bool = False
    deps: bool = True
    inherit_env: bool = False
    isolate: bool = True
    link_in_bin: bool | None = None
    link_in_man1: bool | None = None
    link_in_opt: bool | None = None
    prefix_check: bool = True
    private: bool = False
    push: bool = False
    quiet: bool = False
    reinstall: bool = False
    update_ldconfig: bool = False
    verbose: bool = False
    # Passthrough configuration args (CMake -D style).
    passthrough_args: list[str] = field(default_factory=list)


# -- Helper functions ---------------------------------------------------------


def _run(
    *args: str,
    sudo: bool = False,
    capture: bool = False,
    check: bool = True,
) -> subprocess.CompletedProcess:
    """Run a shell command."""
    cmd = list(args)
    if sudo:
        cmd = ["sudo", *cmd]
    return subprocess.run(cmd, capture_output=capture, text=True, check=check)


def _koopa_prefix() -> str:
    """Return koopa installation prefix."""
    p = Path(__file__).resolve()
    return str(p.parents[4])


def _app_prefix() -> str:
    """Return koopa app prefix."""
    return os.path.join(_koopa_prefix(), "app")


def _opt_prefix() -> str:
    """Return koopa opt prefix."""
    return os.path.join(_koopa_prefix(), "opt")


def _bin_prefix() -> str:
    """Return koopa bin prefix."""
    return os.path.join(_koopa_prefix(), "bin")


def _man1_prefix() -> str:
    """Return koopa man1 prefix."""
    return os.path.join(_koopa_prefix(), "share", "man", "man1")


def _cpu_count() -> int:
    """Return CPU count."""
    return os.cpu_count() or 1


def _import_app_json() -> dict[str, Any]:
    """Import app.json data."""
    json_path = os.path.join(
        _koopa_prefix(),
        "etc",
        "koopa",
        "app.json",
    )
    with open(json_path) as f:
        return json.load(f)


def _app_json_version(key: str) -> str:
    """Get application version from app.json."""
    data = _import_app_json()
    entry = data.get(key, {})
    if isinstance(entry, dict):
        return entry.get("version", "")
    return ""


def _app_json_bin(name: str) -> list[str]:
    """Get bin names for an app from app.json."""
    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        bins = entry.get("bin", [])
        if isinstance(bins, str):
            return [bins]
        if isinstance(bins, list):
            return bins
    return []


def _app_json_man1(name: str) -> list[str]:
    """Get man1 page names for an app from app.json."""
    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        man1 = entry.get("man1", [])
        if isinstance(man1, str):
            return [man1]
        if isinstance(man1, list):
            return man1
    return []


def _app_dependencies(name: str) -> list[str]:
    """Get application dependencies from app.json."""
    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        deps = entry.get("dependencies", [])
        if isinstance(deps, str):
            return [deps]
        if isinstance(deps, list):
            return deps
    return []


def _can_install_binary() -> bool:
    """Check if binary installation is available."""
    return os.environ.get("KOOPA_CAN_INSTALL_BINARY", "") == "1"


def _can_push_binary() -> bool:
    """Check if binary push is available."""
    return os.environ.get("KOOPA_CAN_PUSH_BINARY", "") == "1"


def _has_private_access() -> bool:
    """Check if user has private AWS S3 access."""
    result = subprocess.run(
        ["aws", "sts", "get-caller-identity", "--profile", "acidgenomics"],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0


def _os_string() -> str:
    """Get OS string for binary packages."""
    if is_macos():
        return "macos"
    if is_linux():
        try:
            with open("/etc/os-release") as f:
                for line in f:
                    if line.startswith("ID="):
                        return line.split("=", 1)[1].strip().strip('"')
        except FileNotFoundError:
            pass
    return "linux"


def _arch2() -> str:
    """Get architecture string (e.g. 'amd64', 'arm64')."""
    machine = platform.machine()
    mapping = {"x86_64": "amd64", "aarch64": "arm64", "arm64": "arm64"}
    return mapping.get(machine, machine)


# -- Link helpers -------------------------------------------------------------


def link_in_opt(*, name: str, source: str) -> None:
    """Create symlink in koopa opt/ directory."""
    target = os.path.join(_opt_prefix(), name)
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)
    if os.path.islink(target):
        os.unlink(target)
    os.symlink(source, target)


def link_in_bin(*, name: str, source: str) -> None:
    """Create symlink in koopa bin/ directory."""
    target = os.path.join(_bin_prefix(), name)
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)
    if os.path.islink(target):
        os.unlink(target)
    os.symlink(source, target)


def link_in_man1(*, name: str, source: str) -> None:
    """Create symlink in koopa man1/ directory."""
    target = os.path.join(_man1_prefix(), name)
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)
    if os.path.islink(target):
        os.unlink(target)
    os.symlink(source, target)


# -- Binary package installer -------------------------------------------------


def install_app_from_binary_package(*prefixes: str) -> None:
    """Install app from pre-built binary package.

    Downloads a pre-built tarball from the private S3 bucket and extracts
    it into the target prefix. Inspired by Homebrew bottles.
    """
    if not prefixes:
        msg = "At least one prefix is required."
        raise ValueError(msg)
    arch = _arch2()
    aws_profile = "acidgenomics"
    binary_prefix = "/opt/koopa"
    koopa_prefix = _koopa_prefix()
    os_str = _os_string()
    s3_bucket = "s3://private.koopa.acidgenomics.com/binaries"
    if koopa_prefix != binary_prefix:
        msg = (
            f"Binary package installation not supported for koopa install "
            f"located at '{koopa_prefix}'. Koopa must be installed at "
            f"default '{binary_prefix}' location."
        )
        raise RuntimeError(msg)
    tmp_dir = tempfile.mkdtemp(prefix="koopa-binary-")
    try:
        for prefix in prefixes:
            prefix_path = os.path.realpath(prefix)
            name = os.path.basename(os.path.dirname(prefix_path))
            version = os.path.basename(prefix_path)
            tar_file = os.path.join(tmp_dir, f"{name}-{version}.tar.gz")
            tar_url = f"{s3_bucket}/{os_str}/{arch}/{name}/{version}.tar.gz"
            _run(
                "aws",
                "s3",
                "cp",
                "--profile",
                aws_profile,
                tar_url,
                tar_file,
            )
            if not os.path.isfile(tar_file):
                msg = f"Failed to download binary: {tar_file}"
                raise FileNotFoundError(msg)
            _run("tar", "-Pxz", "-f", tar_file)
            # Touch marker file.
            Path(os.path.join(prefix_path, ".koopa-binary")).touch()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


# -- Subshell installer -------------------------------------------------------


# -- Push build helper --------------------------------------------------------


def push_app_build(name: str) -> None:
    """Push completed build to AWS S3 bucket."""
    arch = _arch2()
    os_str = _os_string()
    s3_bucket = "s3://private.koopa.acidgenomics.com/binaries"
    app_dir = os.path.join(_app_prefix(), name)
    if not os.path.isdir(app_dir):
        msg = f"App directory does not exist: {app_dir}"
        raise FileNotFoundError(msg)
    # Find the version directory.
    versions = sorted(os.listdir(app_dir))
    if not versions:
        msg = f"No version found for app: {name}"
        raise FileNotFoundError(msg)
    version = versions[-1]
    prefix = os.path.join(app_dir, version)
    fd, tar_file = tempfile.mkstemp(suffix=".tar.gz", prefix="koopa-push-")
    os.close(fd)
    try:
        _run("tar", "-Pcz", "-f", tar_file, prefix)
        tar_url = f"{s3_bucket}/{os_str}/{arch}/{name}/{version}.tar.gz"
        _run(
            "aws",
            "s3",
            "cp",
            "--profile",
            "acidgenomics",
            tar_file,
            tar_url,
        )
    finally:
        if os.path.isfile(tar_file):
            os.unlink(tar_file)


# -- Main install function ----------------------------------------------------


def install_app(  # noqa: C901, PLR0912, PLR0915
    config: InstallConfig,
) -> None:
    """Install application in a versioned directory structure.

    This is the main entry point. It resolves version, handles dependencies,
    manages prefix creation, delegates to the binary or subshell installer,
    and performs post-install linking.

    Args:
        config: An ``InstallConfig`` dataclass with installation parameters.
    """
    if not config.name:
        msg = "--name is required."
        raise ValueError(msg)
    if config.verbose:
        os.environ["KOOPA_VERBOSE"] = "1"
    # Resolve mode-specific defaults.
    if config.mode != "shared":
        config.deps = False
    if config.mode == "system":
        if is_macos():
            config.platform = "macos"
        elif is_linux():
            config.platform = _os_string()
    if not config.version_key:
        config.version_key = config.name
    # Resolve version from app.json if not provided.
    current_version = ""
    with contextlib.suppress(FileNotFoundError, KeyError, json.JSONDecodeError):
        current_version = _app_json_version(config.version_key)
    if not config.version:
        config.version = current_version
    app_dir = _app_prefix()
    # -- Mode-specific configuration ------------------------------------------
    if config.mode == "shared":
        if not is_owner():
            msg = "Only the koopa owner can install shared apps."
            raise PermissionError(msg)
        if not config.prefix:
            config.auto_prefix = True
            v2 = config.version
            # Shorten git commit to 7 characters.
            if len(v2) == 40:
                v2 = v2[:7]
            config.prefix = os.path.join(app_dir, config.name, v2)
        if config.version != current_version:
            config.link_in_bin = False
            config.link_in_man1 = False
            config.link_in_opt = False
        else:
            if config.link_in_bin is None:
                config.link_in_bin = True
            if config.link_in_man1 is None:
                config.link_in_man1 = True
            if config.link_in_opt is None:
                config.link_in_opt = True
    elif config.mode == "system":
        if not is_owner():
            msg = "Only the koopa owner can install system apps."
            raise PermissionError(msg)
        if not is_admin():
            msg = "Admin/root access is required for system installs."
            raise PermissionError(msg)
        config.isolate = False
        config.link_in_bin = False
        config.link_in_man1 = False
        config.link_in_opt = False
        config.prefix_check = False
        config.push = False
        if is_linux():
            config.update_ldconfig = True
    elif config.mode == "user":
        config.link_in_bin = False
        config.link_in_man1 = False
        config.link_in_opt = False
        config.push = False
    # -- Private access check -------------------------------------------------
    if (config.binary or config.private or config.push) and not _has_private_access():
        msg = "Private AWS access is required."
        raise PermissionError(msg)
    # -- Handle existing prefix -----------------------------------------------
    if config.prefix and config.prefix_check and os.path.isdir(config.prefix):
        stdout_log = os.path.join(config.prefix, ".install", "stdout.log")
        stdout_log_legacy = os.path.join(config.prefix, ".koopa-install-stdout.log")
        if not os.path.isfile(stdout_log) and not os.path.isfile(stdout_log_legacy):
            config.reinstall = True
        if config.reinstall:
            if not config.quiet:
                print(
                    f"Uninstalling '{config.name}' at '{config.prefix}'.",
                    file=sys.stderr,
                )
            shutil.rmtree(config.prefix, ignore_errors=True)
        if os.path.isdir(config.prefix):
            return
    # -- Install dependencies -------------------------------------------------
    if config.deps:
        deps = _app_dependencies(config.name)
        if deps:
            if not config.quiet:
                print(
                    f"{config.name} dependencies: {', '.join(deps)}",
                    file=sys.stderr,
                )
            for dep in deps:
                dep_opt = os.path.join(_opt_prefix(), dep)
                if os.path.exists(dep_opt):
                    continue
                dep_config = InstallConfig(name=dep)
                if config.bootstrap:
                    dep_config.bootstrap = True
                if config.verbose:
                    dep_config.verbose = True
                install_app(dep_config)
    # -- Start install --------------------------------------------------------
    if not config.quiet:
        if config.prefix:
            print(
                f"Installing '{config.name}' at '{config.prefix}'.",
                file=sys.stderr,
            )
        else:
            print(
                f"Installing '{config.name}'.",
                file=sys.stderr,
            )
    # Create prefix directory.
    if config.prefix and not os.path.isdir(config.prefix):
        os.makedirs(config.prefix, exist_ok=True)
    # -- Dispatch to installer ------------------------------------------------
    from koopa.installers import get_python_installer, has_python_installer
    from koopa.progress import BuildProgress

    orig_cwd = os.getcwd()
    tmp_dir = tempfile.mkdtemp(prefix="koopa-install-")
    os.chdir(tmp_dir)
    try:
        with BuildProgress(config.name, quiet=config.quiet) as progress:
            if config.binary:
                if config.mode != "shared" or not config.prefix:
                    msg = "Binary install requires shared mode and a prefix."
                    raise RuntimeError(msg)
                install_app_from_binary_package(config.prefix)
            elif has_python_installer(config.name, config.platform, config.mode):
                installer_fn = get_python_installer(config.name, config.platform, config.mode)
                installer_fn(
                    name=config.name,
                    version=config.version,
                    prefix=config.prefix,
                    passthrough_args=config.passthrough_args,
                )
            else:
                msg = f"No Python installer for '{config.name}' ({config.platform}/{config.mode})."
                raise FileNotFoundError(msg)
    except Exception:
        if config.prefix and os.path.isdir(config.prefix):
            shutil.rmtree(config.prefix, ignore_errors=True)
        raise
    finally:
        os.chdir(orig_cwd)
        shutil.rmtree(tmp_dir, ignore_errors=True)
    # -- Post-install: linking ------------------------------------------------
    if config.mode == "shared":
        if config.link_in_opt:
            link_in_opt(name=config.name, source=config.prefix)
        if config.link_in_bin:
            bins = _app_json_bin(config.name)
            for b in bins:
                source = os.path.join(config.prefix, "bin", b)
                link_in_bin(name=b, source=source)
        if config.link_in_man1:
            man1_names = _app_json_man1(config.name)
            for m in man1_names:
                mf1 = os.path.join(
                    config.prefix,
                    "share",
                    "man",
                    "man1",
                    m,
                )
                mf2 = os.path.join(config.prefix, "man", "man1", m)
                if os.path.isfile(mf1):
                    link_in_man1(name=m, source=mf1)
                elif os.path.isfile(mf2):
                    link_in_man1(name=m, source=mf2)
        if config.push:
            push_app_build(config.name)
    elif config.mode == "system":
        if config.update_ldconfig:
            _run("ldconfig", sudo=True, check=False)
    if not config.quiet:
        duration = progress.elapsed_formatted
        if config.prefix:
            print(
                f"Successfully installed '{config.name}' at '{config.prefix}' in {duration}.",
                file=sys.stderr,
            )
        else:
            print(
                f"Successfully installed '{config.name}' in {duration}.",
                file=sys.stderr,
            )


# -- Isolated subshell runner -------------------------------------------------


# -- GNU app installer --------------------------------------------------------


def install_gnu_app(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    compress_ext: str = "gz",
    mirror: str = "https://ftpmirror.gnu.org",
    package_name: str = "",
    parent_name: str = "",
    non_gnu_mirror: bool = False,
    conf_args: list[str] | None = None,
    jobs: int | None = None,
) -> None:
    """Build and install a GNU package from source.

    Positional arguments are passed to configure script.
    Converted from install-gnu-app.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if not package_name:
        package_name = name
    if not parent_name:
        parent_name = name
    if jobs is None:
        jobs = _cpu_count()
    if non_gnu_mirror:
        mirror = "https://download.savannah.nongnu.org/releases"
    all_conf_args = list(conf_args or [])
    all_conf_args.append(f"--prefix={prefix}")
    os.environ["FORCE_UNSAFE_CONFIGURE"] = "1"
    url = f"{mirror}/{parent_name}/{package_name}-{version}.tar.{compress_ext}"
    _run("curl", "-LO", url)
    tarball = os.path.basename(url)
    os.makedirs("src", exist_ok=True)
    _run("tar", "-xf", tarball, "-C", "src", "--strip-components=1")
    os.chdir("src")
    _run("./configure", *all_conf_args)
    _run("make", f"-j{jobs}")
    _run("make", "install")


# -- Go package installer -----------------------------------------------------


def build_go_package(
    *,
    url: str,
    prefix: str = "",
    name: str = "",
    version: str = "",
    bin_name: str = "",
    build_cmd: str = "",
    ldflags: str = "",
    mod: str = "",
    tags: str = "",
) -> None:
    """Build a Go package from source using ``go build``."""
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    go = shutil.which("go")
    if go is None:
        msg = "go not found."
        raise FileNotFoundError(msg)
    if not bin_name:
        bin_name = name
    gobin = os.path.join(prefix, "bin")
    gocache = tempfile.mkdtemp(prefix="koopa-gocache-")
    gopath = tempfile.mkdtemp(prefix="koopa-gopath-")
    os.makedirs(gobin, exist_ok=True)
    env = os.environ.copy()
    env["GOBIN"] = gobin
    env["GOCACHE"] = gocache
    env["GOPATH"] = gopath
    build_args: list[str] = []
    if ldflags:
        build_args.extend(["-ldflags", ldflags])
    if mod:
        build_args.extend(["-mod", mod])
    if tags:
        build_args.extend(["-tags", tags])
    build_args.extend(["-o", os.path.join(prefix, "bin", bin_name)])
    if build_cmd:
        build_args.append(build_cmd)
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    try:
        subprocess.run([go, "build", *build_args], env=env, check=True)
    finally:
        shutil.rmtree(gocache, ignore_errors=True)
        shutil.rmtree(gopath, ignore_errors=True)


def install_go_package(
    *,
    url: str,
    prefix: str = "",
) -> None:
    """Install a Go package using ``go install``.

    Converted from install-go-package.sh.
    """
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    go = shutil.which("go")
    if go is None:
        msg = "go not found."
        raise FileNotFoundError(msg)
    gobin = os.path.join(prefix, "bin")
    gocache = tempfile.mkdtemp(prefix="koopa-gocache-")
    gopath = tempfile.mkdtemp(prefix="koopa-gopath-")
    os.makedirs(gobin, exist_ok=True)
    env = os.environ.copy()
    env["GOBIN"] = gobin
    env["GOCACHE"] = gocache
    env["GOPATH"] = gopath
    try:
        subprocess.run([go, "install", url], env=env, check=True)
    finally:
        shutil.rmtree(gocache, ignore_errors=True)
        shutil.rmtree(gopath, ignore_errors=True)


# -- Node.js package installer ------------------------------------------------


def install_node_package(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    extra_packages: list[str] | None = None,
) -> None:
    """Install a Node.js package using npm.

    Converted from install-node-package.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    npm = shutil.which("npm")
    if npm is None:
        msg = "npm not found."
        raise FileNotFoundError(msg)
    cache_dir = tempfile.mkdtemp(prefix="koopa-npm-cache-")
    env = os.environ.copy()
    env["NPM_CONFIG_PREFIX"] = prefix
    env["NPM_CONFIG_UPDATE_NOTIFIER"] = "false"
    install_args = [
        "--build-from-source",
        f"--cache={cache_dir}",
        "--global",
        "--loglevel=silly",
        "--no-audit",
        "--no-fund",
        f"{name}@{version}",
    ]
    if os.getuid() == 0:
        install_args.insert(0, "--unsafe-perm")
    if extra_packages:
        install_args.extend(extra_packages)
    try:
        subprocess.run([npm, "install", *install_args], env=env, check=True)
    finally:
        shutil.rmtree(cache_dir, ignore_errors=True)


# -- Python package installer -------------------------------------------------


def install_python_package(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    pip_name: str = "",
    egg_name: str = "",
    python_version: str = "",
    extra_packages: list[str] | None = None,
    no_binary: bool = False,
) -> None:
    """Install a Python package as a virtual environment application.

    Creates a venv in ``<prefix>/libexec`` and symlinks binaries into
    ``<prefix>/bin``. Converted from install-python-package.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if not egg_name:
        egg_name = name.replace("-", "_")
    if not pip_name:
        pip_name = egg_name
    # Resolve python executable.
    python_cmd = "python3"
    if python_version:
        python_cmd = f"python{python_version}"
    python = shutil.which(python_cmd)
    if python is None:
        msg = f"{python_cmd} not found."
        raise FileNotFoundError(msg)
    libexec = os.path.join(prefix, "libexec")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    # Create venv.
    subprocess.run([python, "-m", "venv", libexec], check=True)
    venv_pip = os.path.join(libexec, "bin", "pip")
    pip_args = [venv_pip, "install"]
    if no_binary:
        pip_args.extend(["--no-binary", ":all:"])
    pip_args.append(f"{pip_name}=={version}")
    if extra_packages:
        pip_args.extend(extra_packages)
    subprocess.run(pip_args, check=True)
    # Link binaries from libexec/bin into prefix/bin.
    libexec_bin = os.path.join(libexec, "bin")
    if os.path.isdir(libexec_bin):
        for entry in os.listdir(libexec_bin):
            src = os.path.join(libexec_bin, entry)
            dst = os.path.join(bin_dir, entry)
            if os.path.isfile(src) and not entry.startswith(("python", "pip", "activate")):
                if os.path.islink(dst):
                    os.unlink(dst)
                os.symlink(src, dst)


# -- Rust package installer ---------------------------------------------------


def install_rust_package(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    features: str = "",
    git_url: str = "",
    tag: str = "",
    with_openssl: bool = False,
    jobs: int | None = None,
) -> None:
    """Install a Rust package using ``cargo install``.

    Converted from install-rust-package.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if jobs is None:
        jobs = _cpu_count()
    cargo = shutil.which("cargo")
    if cargo is None:
        msg = "cargo not found."
        raise FileNotFoundError(msg)
    cargo_home = tempfile.mkdtemp(prefix="koopa-cargo-")
    env = os.environ.copy()
    env["CARGO_HOME"] = cargo_home
    env["CARGO_NET_GIT_FETCH_WITH_CLI"] = "true"
    env["RUST_BACKTRACE"] = "full"
    if with_openssl:
        openssl_dir = os.path.join(_app_prefix(), "openssl")
        if os.path.isdir(openssl_dir):
            env["OPENSSL_DIR"] = openssl_dir
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    install_args = [
        cargo,
        "install",
        "--jobs",
        str(jobs),
        "--locked",
        "--root",
        prefix,
        "--verbose",
        "--version",
        version,
    ]
    if features:
        install_args.extend(["--features", features])
    if git_url:
        install_args.extend(["--git", git_url])
    if tag:
        install_args.extend(["--tag", tag])
    install_args.append(name)
    try:
        subprocess.run(install_args, env=env, check=True)
    finally:
        shutil.rmtree(cargo_home, ignore_errors=True)


# -- Ruby package installer ---------------------------------------------------


def install_ruby_package(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    jobs: int | None = None,
) -> None:
    """Install a Ruby package using Bundler.

    Creates a Gemfile in ``<prefix>/libexec`` and runs ``bundle install``
    + ``bundle binstubs``. Converted from install-ruby-package.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if jobs is None:
        jobs = _cpu_count()
    ruby_opt = os.path.join(_opt_prefix(), "ruby")
    ruby_bin = os.path.join(os.path.realpath(ruby_opt), "bin") if os.path.isdir(ruby_opt) else None

    def _find(cmd: str) -> str | None:
        if ruby_bin:
            candidate = os.path.join(ruby_bin, cmd)
            if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                return candidate
        return shutil.which(cmd)

    bundle = _find("bundle")
    ruby = _find("ruby")
    if bundle is None or ruby is None:
        msg = "bundle and ruby are required."
        raise FileNotFoundError(msg)
    libexec = os.path.join(prefix, "libexec")
    os.makedirs(libexec, exist_ok=True)
    gemfile = os.path.join(libexec, "Gemfile")
    gemfile_content = f'source "https://rubygems.org"\ngem "{name}", "{version}"\n'
    Path(gemfile).write_text(gemfile_content)
    bin_dir = os.path.join(prefix, "bin")
    subprocess.run(
        [bundle, "config", "set", "--local", "bin", bin_dir],
        cwd=libexec,
        check=True,
    )
    subprocess.run(
        [bundle, "config", "set", "--local", "path", "bundle"],
        cwd=libexec,
        check=True,
    )
    subprocess.run(
        [
            bundle,
            "install",
            f"--gemfile={gemfile}",
            f"--jobs={jobs}",
            "--retry=3",
            "--standalone",
        ],
        cwd=libexec,
        check=True,
    )
    subprocess.run(
        [
            bundle,
            "binstubs",
            name,
            f"--shebang={ruby}",
            "--standalone",
        ],
        cwd=libexec,
        check=True,
    )


# -- Perl package installer ---------------------------------------------------


def install_perl_package(
    *,
    cpan_path: str,
    version: str = "",
    prefix: str = "",
    dependencies: list[str] | None = None,
    jobs: int | None = None,
) -> None:
    """Install a Perl package using CPAN.

    Converted from install-perl-package.sh.
    """
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if jobs is None:
        jobs = _cpu_count()
    cpan = shutil.which("cpan")
    perl = shutil.which("perl")
    make = shutil.which("make") or "/usr/bin/make"
    if cpan is None or perl is None:
        msg = "cpan and perl are required."
        raise FileNotFoundError(msg)
    tmp_cpan = tempfile.mkdtemp(prefix="koopa-cpan-")
    cpan_config_dir = os.path.join(tmp_cpan, "CPAN")
    os.makedirs(cpan_config_dir, exist_ok=True)
    cpan_config = os.path.join(cpan_config_dir, "MyConfig.pm")
    config_content = f"""$CPAN::Config = {{
  'build_dir' => q[{tmp_cpan}/build],
  'cpan_home' => q[{tmp_cpan}],
  'keep_source_where' => q[{tmp_cpan}/sources],
  'make' => q[{make}],
  'make_arg' => q[-j{jobs}],
  'make_install_arg' => q[-j{jobs}],
  'makepl_arg' => q[INSTALL_BASE={prefix}],
  'mbuildpl_arg' => q[--install_base {prefix}],
  'prerequisites_policy' => q[follow],
  'urllist' => [q[http://www.cpan.org/]],
  'use_prompt_default' => q[1],
  'halt_on_failure' => q[1],
}};
1;
__END__
"""
    Path(cpan_config).write_text(config_content)
    # Get perl version for lib path.
    result = subprocess.run(
        [perl, "-e", "print $^V"],
        capture_output=True,
        text=True,
        check=True,
    )
    perl_ver = result.stdout.lstrip("v")
    perl_major = perl_ver.split(".")[0]
    lib_prefix = os.path.join(prefix, "lib", f"perl{perl_major}")
    env = os.environ.copy()
    env["PERL5LIB"] = lib_prefix
    try:
        if dependencies:
            subprocess.run(
                [cpan, "-j", cpan_config, *dependencies],
                env=env,
                check=True,
            )
        subprocess.run(
            [cpan, "-j", cpan_config, f"{cpan_path}-{version}.tar.gz"],
            env=env,
            check=True,
        )
    finally:
        shutil.rmtree(tmp_cpan, ignore_errors=True)


# -- Conda package installer --------------------------------------------------


def install_conda_package(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    yaml_file: str = "",
) -> None:
    """Install a conda environment as an application.

    Creates a conda env in ``<prefix>/libexec`` and links binaries into
    ``<prefix>/bin``. Converted from install-conda-package.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    conda = shutil.which("conda")
    if conda is None:
        msg = "conda not found."
        raise FileNotFoundError(msg)
    libexec = os.path.join(prefix, "libexec")
    os.makedirs(libexec, exist_ok=True)
    create_args = [conda, "create", "--yes", f"--prefix={libexec}"]
    # Check if conda-forge channel is configured.
    result = subprocess.run(
        [conda, "config", "--show", "channels"],
        capture_output=True,
        text=True,
        check=True,
    )
    if "conda-forge" not in result.stdout:
        create_args.extend(
            [
                "--channel=conda-forge",
                "--channel=bioconda",
            ]
        )
    if yaml_file:
        create_args.append(f"--file={yaml_file}")
    else:
        create_args.append(f"{name}=={version}")
    subprocess.run(create_args, check=True)
    # Link binaries from libexec/bin into prefix/bin.
    libexec_bin = os.path.join(libexec, "bin")
    bin_dir = os.path.join(prefix, "bin")
    if os.path.isdir(libexec_bin):
        os.makedirs(bin_dir, exist_ok=True)
        for entry in os.listdir(libexec_bin):
            src = os.path.join(libexec_bin, entry)
            dst = os.path.join(bin_dir, entry)
            if os.path.isfile(src) and not os.path.isdir(src):
                if os.path.islink(dst):
                    os.unlink(dst)
                os.symlink(src, dst)


# -- Haskell package installer ------------------------------------------------


def install_haskell_package(
    *,
    name: str = "",
    version: str = "",
    prefix: str = "",
    ghc_version: str = "9.4.7",
    dependencies: list[str] | None = None,
    extra_packages: list[str] | None = None,
    jobs: int | None = None,
) -> None:
    """Install a Haskell package using Cabal and GHCup.

    Converted from install-haskell-package.sh.
    """
    if not name:
        name = os.environ.get("KOOPA_INSTALL_NAME", "")
    if not version:
        version = os.environ.get("KOOPA_INSTALL_VERSION", "")
    if not prefix:
        prefix = os.environ.get("KOOPA_INSTALL_PREFIX", "")
    if jobs is None:
        jobs = _cpu_count()
    cabal = shutil.which("cabal")
    ghcup = shutil.which("ghcup")
    if cabal is None or ghcup is None:
        msg = "cabal and ghcup are required."
        raise FileNotFoundError(msg)
    cabal_dir = tempfile.mkdtemp(prefix="koopa-cabal-")
    ghcup_prefix = tempfile.mkdtemp(prefix="koopa-ghcup-")
    ghc_prefix = tempfile.mkdtemp(prefix=f"koopa-ghc-{ghc_version}-")
    cabal_store = os.path.join(prefix, "libexec", "cabal", "store")
    os.makedirs(cabal_store, exist_ok=True)
    env = os.environ.copy()
    env["CABAL_DIR"] = cabal_dir
    env["GHCUP_INSTALL_BASE_PREFIX"] = ghcup_prefix
    try:
        # Install GHC.
        subprocess.run(
            [ghcup, "install", "ghc", ghc_version, "--isolate", ghc_prefix],
            env=env,
            check=True,
        )
        ghc_bin = os.path.join(ghc_prefix, "bin")
        bin_dir = os.path.join(prefix, "bin")
        os.makedirs(bin_dir, exist_ok=True)
        env["PATH"] = f"{ghc_bin}:{bin_dir}:{env.get('PATH', '')}"
        # Update cabal.
        subprocess.run([cabal, "update"], env=env, check=True)
        # Configure cabal store.
        cabal_config = os.path.join(cabal_dir, "config")
        if os.path.isfile(cabal_config):
            with open(cabal_config, "a") as f:
                f.write(f"store-dir: {cabal_store}\n")
                if dependencies:
                    for dep in dependencies:
                        dep_prefix = os.path.join(_app_prefix(), dep)
                        if os.path.isdir(dep_prefix):
                            f.write(f"extra-include-dirs: {dep_prefix}/include\n")
                            f.write(f"extra-lib-dirs: {dep_prefix}/lib\n")
        # Install.
        install_args = [
            cabal,
            "install",
            "--install-method=copy",
            f"--installdir={bin_dir}",
            f"--jobs={jobs}",
            "--verbose",
            f"{name}-{version}",
        ]
        if extra_packages:
            install_args.extend(extra_packages)
        subprocess.run(install_args, env=env, check=True)
    finally:
        shutil.rmtree(cabal_dir, ignore_errors=True)
        shutil.rmtree(ghcup_prefix, ignore_errors=True)
        shutil.rmtree(ghc_prefix, ignore_errors=True)


# -- Batch / meta installers --------------------------------------------------


def install_all_apps() -> None:
    """Install all supported shared apps."""
    install_shared_apps(mode="all")


def install_default_apps() -> None:
    """Install the default recommended app stack."""
    from koopa.alert import alert_note

    alert_note(
        "This installs missing default apps. To update existing apps, use 'koopa update'.",
    )
    install_shared_apps(mode="default")


def install_shared_apps(mode: str = "default") -> None:
    """Build and install shared apps from source.

    Skips apps that are already fully installed (have an install log).
    Use ``koopa update`` to update outdated apps.
    """
    if mode not in ("all", "default"):
        msg = f"Invalid mode: {mode!r}."
        raise ValueError(msg)
    if not is_owner():
        msg = "Only the koopa owner can install shared apps."
        raise PermissionError(msg)
    if is_macos() and _arch2() == "amd64":
        msg = "No longer supported for Intel Macs."
        raise RuntimeError(msg)
    try:
        import psutil  # type: ignore[import-untyped]  # ty: ignore[unresolved-import]

        mem_gb = psutil.virtual_memory().total / (1024**3)
        mem_gb_cutoff = 6
        if mem_gb < mem_gb_cutoff:
            msg = f"{mem_gb_cutoff} GB of RAM is required."
            raise RuntimeError(msg)
    except ImportError:
        pass
    from koopa.app import shared_apps

    app_names = shared_apps(mode=mode)
    app_dir = _app_prefix()
    for app_name in app_names:
        app_prefix = os.path.join(app_dir, app_name)
        if os.path.isdir(app_prefix):
            versions = [
                d for d in os.listdir(app_prefix) if os.path.isdir(os.path.join(app_prefix, d))
            ]
            if any(
                os.path.isfile(
                    os.path.join(app_prefix, v, ".install", "stdout.log"),
                )
                or os.path.isfile(
                    os.path.join(app_prefix, v, ".koopa-install-stdout.log"),
                )
                for v in versions
            ):
                continue
        cli_install(app_name)


# -- Thin-wrapper install functions -------------------------------------------


def _make_app_installer(
    app_name: str,
    *,
    installer: str = "",
    mode: str = "shared",
    platform: str = "common",
    prefix: str = "",
) -> None:
    """Generic thin-wrapper installer for a named application.

    Most install-*.sh files are simple wrappers around ``koopa_install_app``.
    This function provides the same pattern in Python.
    """
    config = InstallConfig(name=app_name, mode=mode, platform=platform)
    if installer:
        config.installer = installer
    if prefix:
        config.prefix = prefix
    config.binary = _can_install_binary()
    config.push = _can_push_binary()
    install_app(config)


def install_system_app(name: str, **kwargs: str) -> None:
    """Install a system-level application.

    Equivalent to ``koopa_install_app --name=<name> --system``.
    """
    _make_app_installer(name, mode="system", **kwargs)


def install_user_app(name: str, **kwargs: str) -> None:
    """Install a user-level application.

    Equivalent to ``koopa_install_app --name=<name> --user``.
    """
    _make_app_installer(name, mode="user", **kwargs)


# -- Koopa self-installer -----------------------------------------------------


def install_koopa(
    *,
    prefix: str = "",
    shared: bool = False,
    bootstrap: bool = False,
    add_to_user_profile: bool = True,
    interactive: bool = True,
    verbose: bool = False,
) -> None:
    """Install koopa itself.

    Copies the source tree to the target prefix, optionally as a shared
    (system-wide) install. Converted from install-koopa.sh.
    """
    source_prefix = _koopa_prefix()
    xdg_data_home = os.environ.get(
        "XDG_DATA_HOME",
        os.path.join(os.path.expanduser("~"), ".local", "share"),
    )
    system_prefix = "/opt/koopa"
    user_prefix = os.path.join(xdg_data_home, "koopa")
    if is_admin():
        shared = True
    if not prefix:
        prefix = system_prefix if shared else user_prefix
    if verbose:
        os.environ["KOOPA_VERBOSE"] = "1"
    if os.path.isdir(prefix):
        msg = f"Install prefix already exists: {prefix}"
        raise FileExistsError(msg)
    # Copy source tree to target prefix.
    if shared:
        if not is_admin():
            msg = "Admin permissions required for shared install."
            raise PermissionError(msg)
        _run("cp", "-a", source_prefix, prefix, sudo=True)
        uid = str(os.getuid())
        gid = str(os.getgid())
        _run(
            "chown",
            "-R",
            f"{uid}:{gid}",
            prefix,
            sudo=True,
        )
    else:
        shutil.copytree(source_prefix, prefix, symlinks=True)
    os.environ["KOOPA_PREFIX"] = prefix
    if shared:
        xdg_data_link = os.path.join(xdg_data_home, "koopa")
        if not os.path.exists(xdg_data_link):
            os.makedirs(xdg_data_home, exist_ok=True)
            os.symlink(prefix, xdg_data_link)
    if bootstrap:
        cli_install("bash", bootstrap=True)
        cli_install("coreutils", bootstrap=True)
    _update_venv(prefix)


def _zsh_compaudit_set_permissions() -> None:
    """Fix ZSH permissions to ensure compaudit checks pass during compinit."""
    import stat as stat_mod

    uid = os.getuid()
    prefixes = [
        os.path.join(_koopa_prefix(), "lang", "zsh"),
        os.path.join(_opt_prefix(), "zsh", "share", "zsh"),
    ]
    for prefix in prefixes:
        if not os.path.isdir(prefix):
            continue
        st = os.stat(prefix)
        if st.st_uid != uid:
            _run("chown", "-R", str(uid), prefix, sudo=True)
        mode = stat_mod.S_IMODE(st.st_mode)
        access = oct(mode)[-3:]
        if access not in ("700", "744", "755"):
            _run("chmod", "-R", "go-w", prefix, sudo=(st.st_uid != uid))


def update_koopa(*, verbose: bool = False) -> None:
    """Update koopa installation via git pull."""
    from koopa.alert import alert_note
    from koopa.git import git_pull, is_git_repo

    if verbose:
        os.environ["KOOPA_VERBOSE"] = "1"
    prefix = _koopa_prefix()
    if not is_owner():
        msg = f"Current user does not own koopa installation at '{prefix}'."
        raise PermissionError(msg)
    if not is_git_repo(prefix):
        alert_note(f"Pinned release detected at '{prefix}'.")
        return
    git_pull(prefix)
    _update_venv(prefix)
    _zsh_compaudit_set_permissions()


def _update_venv(prefix: str) -> None:
    """Create or update the Python virtual environment with extras."""
    import venv

    from koopa.alert import alert

    python_version_file = os.path.join(prefix, ".python-version")
    if not os.path.isfile(python_version_file):
        return
    venv_dir = os.path.join(prefix, ".venv")
    if not os.path.isdir(venv_dir):
        alert("Creating Python virtual environment.")
        venv.create(venv_dir, with_pip=True)
    venv_pip = os.path.join(venv_dir, "bin", "pip")
    if not os.path.isfile(venv_pip):
        alert("Installing pip into virtual environment.")
        venv_python = os.path.join(venv_dir, "bin", "python3")
        subprocess.run(
            [venv_python, "-m", "ensurepip", "--upgrade"],
            check=True,
        )
    alert("Installing Python package with extras.")
    subprocess.run(
        [venv_pip, "install", "--editable", f"{prefix}[extra]", "--upgrade", "--quiet"],
        check=True,
    )


# -- Update pipeline ----------------------------------------------------------


def update_bootstrap(*, verbose: bool = False) -> None:
    """Update bootstrap if out of date."""
    from koopa.alert import alert, warn
    from koopa.check import check_bootstrap_version

    if check_bootstrap_version():
        return
    alert("Updating bootstrap.")
    try:
        config = InstallConfig(
            name="bootstrap",
            mode="user",
            reinstall=True,
            verbose=verbose,
        )
        install_app(config)
    except Exception as exc:
        warn(f"Failed to update bootstrap: {exc}")


def update_stale_apps(*, verbose: bool = False) -> None:
    """Find and reinstall all outdated or broken shared apps."""
    from koopa.alert import alert, alert_success, warn
    from koopa.check import broken_app_installs, outdated_apps

    if not is_owner():
        return
    outdated = outdated_apps()
    broken = broken_app_installs()
    apps = list(dict.fromkeys(outdated + broken))
    if not apps:
        alert_success("All installed apps are up to date.")
        return
    alert(f"Updating {len(apps)} app(s): {', '.join(apps)}")
    failed: list[str] = []
    for app in apps:
        try:
            cli_install(app, reinstall=True, verbose=verbose)
        except Exception as exc:
            warn(f"Failed to update '{app}': {exc}")
            failed.append(app)
    _update_stale_revdeps(apps, failed=failed, verbose=verbose)
    if failed:
        warn(f"{len(failed)} app(s) failed to update: {', '.join(failed)}")
    else:
        alert_success("All stale apps updated successfully.")


def _update_stale_revdeps(
    updated_apps: list[str],
    *,
    failed: list[str],
    verbose: bool = False,
) -> None:
    """Reinstall reverse dependencies of successfully updated apps."""
    from koopa.alert import alert, warn
    from koopa.app import stale_revdeps

    succeeded = [a for a in updated_apps if a not in failed]
    if not succeeded:
        return
    revdeps = stale_revdeps(succeeded)
    revdeps = [r for r in revdeps if r not in updated_apps and r not in failed]
    if not revdeps:
        return
    alert(f"Updating {len(revdeps)} stale reverse dep(s): {', '.join(revdeps)}")
    for app in revdeps:
        try:
            cli_install(app, reinstall=True, verbose=verbose)
        except Exception as exc:
            warn(f"Failed to update reverse dep '{app}': {exc}")
            failed.append(app)


def remove_unsupported_apps(*, verbose: bool = False) -> None:
    """Remove installed apps that are no longer in app.json or marked removed."""
    from koopa.alert import alert, alert_note, warn
    from koopa.app import stale_revdeps
    from koopa.check import unsupported_apps
    from koopa.uninstall import UninstallConfig, uninstall_app

    if not is_owner():
        return
    apps = unsupported_apps()
    if not apps:
        return
    alert(f"Removing {len(apps)} unsupported app(s): {', '.join(apps)}")
    revdeps = stale_revdeps(apps)
    if revdeps:
        alert_note(
            f"Reverse dependencies will also be updated: {', '.join(revdeps)}",
        )
    for app in apps:
        try:
            config = UninstallConfig(name=app, verbose=verbose)
            uninstall_app(config)
        except Exception as exc:
            warn(f"Failed to remove '{app}': {exc}")
    for dep in revdeps:
        try:
            cli_install(dep, reinstall=True, verbose=verbose)
        except Exception as exc:
            warn(f"Failed to reinstall reverse dep '{dep}': {exc}")


def update_user_apps(*, verbose: bool = False) -> None:
    """Update outdated user-mode apps (git-based)."""
    from koopa.alert import alert, warn
    from koopa.check import _user_app_prefixes, outdated_user_apps
    from koopa.git import git_checkout, git_fetch

    apps = outdated_user_apps()
    if not apps:
        return
    json_data = _import_app_json()
    prefixes = _user_app_prefixes()
    alert(f"Updating {len(apps)} user app(s): {', '.join(apps)}")
    for app in apps:
        prefix = prefixes.get(app, "")
        if not prefix or not os.path.isdir(prefix):
            continue
        version = json_data.get(app, {}).get("version", "")
        if not version:
            continue
        try:
            git_fetch(prefix)
            git_checkout(prefix, ref=version)
        except Exception as exc:
            warn(f"Failed to update user app '{app}': {exc}")


def update_system_apps(*, verbose: bool = False) -> None:
    """Update system-level apps (Homebrew, R, Python) when admin."""
    from koopa.alert import alert_note

    if not is_admin():
        alert_note(
            "Skipping system updates (admin/sudo access required).",
        )
        return
    if is_macos():
        _update_system_homebrew(verbose=verbose)
        _update_system_r(verbose=verbose)
        _update_system_python(verbose=verbose)


def _update_system_homebrew(*, verbose: bool = False) -> None:
    """Update Homebrew if installed."""
    from koopa.alert import alert, warn

    if shutil.which("brew") is None:
        return
    alert("Updating Homebrew.")
    try:
        config = InstallConfig(
            name="homebrew",
            mode="system",
            reinstall=True,
            verbose=verbose,
        )
        install_app(config)
    except Exception as exc:
        warn(f"Failed to update Homebrew: {exc}")


def _update_system_r(*, verbose: bool = False) -> None:
    """Update macOS system R if installed and outdated."""
    from koopa.alert import alert, warn
    from koopa.check import check_macos_system_r

    if check_macos_system_r():
        return
    alert("Updating macOS system R.")
    try:
        config = InstallConfig(
            name="r",
            mode="system",
            platform="macos",
            reinstall=True,
            verbose=verbose,
        )
        install_app(config)
    except Exception as exc:
        warn(f"Failed to update system R: {exc}")


def _update_system_python(*, verbose: bool = False) -> None:
    """Update macOS system Python if installed and outdated."""
    from koopa.alert import alert, warn
    from koopa.check import check_macos_system_python

    if check_macos_system_python():
        return
    json_data = _import_app_json()
    py_keys = sorted(
        (k for k in json_data if k.startswith("python3.")),
        reverse=True,
    )
    if not py_keys:
        return
    py_name = py_keys[0]
    alert(f"Updating macOS system Python ({py_name}).")
    try:
        config = InstallConfig(
            name=py_name,
            mode="system",
            platform="macos",
            reinstall=True,
            verbose=verbose,
        )
        install_app(config)
    except Exception as exc:
        warn(f"Failed to update system Python: {exc}")


# -- Convenience CLI entry point ----------------------------------------------


def cli_install(
    name: str,
    *,
    reinstall: bool = False,
    bootstrap: bool = False,
    verbose: bool = False,
) -> None:
    """High-level CLI entry point for installing an app by name.

    This is the Python equivalent of ``koopa install <name>``.
    """
    config = InstallConfig(
        name=name,
        reinstall=reinstall,
        bootstrap=bootstrap,
        verbose=verbose,
        binary=_can_install_binary(),
        push=_can_push_binary(),
    )
    install_app(config)
