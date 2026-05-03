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

from koopa.archive import extract, is_valid_archive
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


def _bash_completions_prefix() -> str:
    """Return koopa central bash-completion completions directory."""
    return os.path.join(_koopa_prefix(), "share", "bash-completion", "completions")


def _fish_completions_prefix() -> str:
    """Return koopa central fish completions directory."""
    return os.path.join(_koopa_prefix(), "share", "fish", "vendor_completions.d")


def _zsh_completions_prefix() -> str:
    """Return koopa central zsh completions directory."""
    return os.path.join(_koopa_prefix(), "share", "zsh", "site-functions")


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


def _resolve_alias(name: str) -> str:
    """Resolve app alias to its target name."""
    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        alias = entry.get("alias_of", "")
        if alias:
            return alias
    return name


def _app_json_installer(name: str) -> str:
    """Get installer name from app.json, if different from app name."""
    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        return entry.get("installer", "")
    return ""


def _app_dependencies(name: str) -> list[str]:
    """Get application dependencies from app.json."""
    from koopa.app import _resolve_dep_dict
    from koopa.os import os_id

    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        deps = entry.get("dependencies", [])
        if isinstance(deps, str):
            return [deps]
        if isinstance(deps, dict):
            return _resolve_dep_dict(deps, {"os_id": os_id()})
        if isinstance(deps, list):
            return deps
    return []


def _app_build_dependencies(name: str) -> list[str]:
    """Get application build dependencies from app.json."""
    from koopa.app import _resolve_dep_dict
    from koopa.os import os_id

    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        deps = entry.get("build_dependencies", [])
        if isinstance(deps, str):
            return [deps]
        if isinstance(deps, dict):
            return _resolve_dep_dict(deps, {"os_id": os_id()})
        if isinstance(deps, list):
            return deps
    return []


def _app_json_revision(name: str) -> int:
    """Get recipe revision from app.json (default 0)."""
    data = _import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        return int(entry.get("revision", 0))
    return 0


def _can_build_binary() -> bool:
    """Check if running on a designated builder machine (KOOPA_BUILDER=1)."""
    return os.environ.get("KOOPA_BUILDER", "0") == "1"


def _has_private_access() -> bool:
    """Check for the acidgenomics profile in ~/.aws/credentials."""
    credentials = os.path.join(os.path.expanduser("~"), ".aws", "credentials")
    if not os.path.isfile(credentials):
        return False
    import re

    with open(credentials) as f:
        return bool(re.search(r"^\[acidgenomics\]$", f.read(), re.MULTILINE))


def _can_install_binary() -> bool:
    """Check if binary installation is available.

    Mirrors koopa_can_install_binary:
    - KOOPA_CAN_INSTALL_BINARY=0 -> deny
    - KOOPA_CAN_INSTALL_BINARY=1 -> allow
    - KOOPA_BUILDER=1 -> deny (builders always build from source)
    - otherwise: allow only if acidgenomics AWS profile is present
    """
    flag = os.environ.get("KOOPA_CAN_INSTALL_BINARY", "")
    if flag == "0":
        return False
    if flag == "1":
        return True
    if _can_build_binary():
        return False
    return _has_private_access()


def _can_push_binary() -> bool:
    """Check if binary push to S3 is available.

    Mirrors koopa_can_push_binary:
    - acidgenomics AWS profile must be present in ~/.aws/credentials
    - KOOPA_BUILDER=1 must be set
    - AWS_CLOUDFRONT_DISTRIBUTION_ID must be set
    - aws CLI must be executable

    Note: aws-cli cannot push its own binary during its own post-install
    (aws not yet in PATH at that point). Use 'koopa develop push-app-build
    aws-cli' after installation completes.
    """
    if not _has_private_access():
        return False
    if not _can_build_binary():
        return False
    if not os.environ.get("AWS_CLOUDFRONT_DISTRIBUTION_ID", ""):
        return False
    return shutil.which("aws") is not None


def _os_string() -> str:
    """Get OS string for binary package S3 paths (e.g. 'macos-15', 'ubuntu-24')."""
    if is_macos():
        ver = platform.mac_ver()[0]
        major = ver.split(".")[0] if ver else ""
        return f"macos-{major}" if major else "macos"
    if is_linux():
        try:
            data: dict[str, str] = {}
            with open("/etc/os-release") as f:
                for line in f:
                    if "=" in line:
                        k, v = line.strip().split("=", 1)
                        data[k] = v.strip('"')
            os_id = data.get("ID", "linux")
            version = data.get("VERSION_ID", "")
            major = version.split(".")[0] if version else ""
            return f"{os_id}-{major}" if major else os_id
        except FileNotFoundError:
            pass
    return "linux"


def _arch2() -> str:
    """Get architecture string (e.g. 'amd64', 'arm64')."""
    machine = platform.machine().lower()
    mapping = {"x86_64": "amd64", "amd64": "amd64", "aarch64": "arm64", "arm64": "arm64"}
    return mapping.get(machine, machine)


# -- Link helpers -------------------------------------------------------------


def link_in_opt(*, name: str, source: str) -> None:
    """Create symlink in koopa opt/ directory."""
    if not os.path.exists(source):
        msg = f"Link source does not exist: {source!r}"
        raise FileNotFoundError(msg)
    target = os.path.join(_opt_prefix(), name)
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)
    if os.path.islink(target):
        os.unlink(target)
    os.symlink(source, target)


def link_in_bin(*, name: str, source: str) -> None:
    """Create symlink in koopa bin/ directory."""
    if not os.path.isfile(source):
        msg = f"Binary does not exist: {source!r}"
        raise FileNotFoundError(msg)
    target = os.path.join(_bin_prefix(), name)
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)
    if os.path.islink(target):
        os.unlink(target)
    os.symlink(source, target)


def link_in_man1(*, name: str, source: str) -> None:
    """Create symlink in koopa man1/ directory."""
    if not os.path.isfile(source):
        msg = f"Man page does not exist: {source!r}"
        raise FileNotFoundError(msg)
    target = os.path.join(_man1_prefix(), name)
    target_dir = os.path.dirname(target)
    os.makedirs(target_dir, exist_ok=True)
    if os.path.islink(target):
        os.unlink(target)
    os.symlink(source, target)


def _find_bash_completion_files(prefix: str) -> list[tuple[str, str]]:
    """Return ``(source_path, filename)`` for bash completion files in an app prefix.

    Scans both the prefix root and prefix/libexec for:
      - share/bash-completion/completions/   (standard)
      - share/bash-completions/completions/  (aws-cli non-standard spelling)
      - etc/bash_completion.d/
    """
    results: list[tuple[str, str]] = []
    for root in (prefix, os.path.join(prefix, "libexec")):
        for subdir in (
            os.path.join(root, "share", "bash-completion", "completions"),
            os.path.join(root, "share", "bash-completions", "completions"),
            os.path.join(root, "etc", "bash_completion.d"),
        ):
            if os.path.isdir(subdir):
                for entry in os.listdir(subdir):
                    source = os.path.join(subdir, entry)
                    if os.path.isfile(source):
                        results.append((source, entry))
    return results


def _find_fish_completion_files(prefix: str) -> list[tuple[str, str]]:
    """Return ``(source_path, filename)`` for fish completion files in an app prefix.

    Scans both the prefix root and prefix/libexec for:
      - share/fish/vendor_completions.d/
    """
    results: list[tuple[str, str]] = []
    for root in (prefix, os.path.join(prefix, "libexec")):
        subdir = os.path.join(root, "share", "fish", "vendor_completions.d")
        if os.path.isdir(subdir):
            for entry in os.listdir(subdir):
                source = os.path.join(subdir, entry)
                if os.path.isfile(source):
                    results.append((source, entry))
    return results


def _find_zsh_completion_files(prefix: str) -> list[tuple[str, str]]:
    """Return ``(source_path, filename)`` for zsh completion files in an app prefix.

    Scans both the prefix root and prefix/libexec for:
      - share/zsh/site-functions/
    """
    results: list[tuple[str, str]] = []
    for root in (prefix, os.path.join(prefix, "libexec")):
        subdir = os.path.join(root, "share", "zsh", "site-functions")
        if os.path.isdir(subdir):
            for entry in os.listdir(subdir):
                source = os.path.join(subdir, entry)
                if os.path.isfile(source):
                    results.append((source, entry))
    return results


def _link_completions(prefix: str, central_dir: str, files: list[tuple[str, str]]) -> None:
    """Symlink a list of completion files into a central directory."""
    for source, name in files:
        os.makedirs(central_dir, exist_ok=True)
        target = os.path.join(central_dir, name)
        if os.path.islink(target):
            os.unlink(target)
        os.symlink(source, target)


def link_in_bash_completions(prefix: str) -> None:
    """Symlink bash completion files from an app prefix into the central dir."""
    _link_completions(
        prefix,
        _bash_completions_prefix(),
        _find_bash_completion_files(prefix),
    )


def link_in_fish_completions(prefix: str) -> None:
    """Symlink fish completion files from an app prefix into the central dir."""
    _link_completions(
        prefix,
        _fish_completions_prefix(),
        _find_fish_completion_files(prefix),
    )


def link_in_zsh_completions(prefix: str) -> None:
    """Symlink zsh completion files from an app prefix into the central dir."""
    _link_completions(
        prefix,
        _zsh_completions_prefix(),
        _find_zsh_completion_files(prefix),
    )


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
    config.name = _resolve_alias(config.name)
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
        install_marker = os.path.join(config.prefix, ".install")
        if not os.path.isdir(install_marker):
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
        build_deps = _app_build_dependencies(config.name)
        deps = _app_dependencies(config.name)
        all_deps = list(dict.fromkeys(build_deps + deps))
        if all_deps:
            if not config.quiet:
                from koopa.alert import alert_note

                alert_note(f"{config.name}: installing with dependencies: {', '.join(all_deps)}")
            for dep in all_deps:
                resolved_dep = _resolve_alias(dep)
                dep_opt = os.path.join(_opt_prefix(), resolved_dep)
                if os.path.exists(dep_opt):
                    continue
                dep_config = InstallConfig(
                    name=dep,
                    passthrough_args=_build_passthrough_args(dep),
                )
                if config.verbose:
                    dep_config.verbose = True
                install_app(dep_config)
    # -- Start install --------------------------------------------------------
    if not config.quiet:
        from koopa.alert import alert_install_start

        alert_install_start(config.name, config.prefix or "")
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
        with BuildProgress(config.name, quiet=config.quiet, verbose=config.verbose) as progress:
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
                installer_key = _app_json_installer(config.name)
                if installer_key and has_python_installer(
                    installer_key, config.platform, config.mode
                ):
                    installer_fn = get_python_installer(installer_key, config.platform, config.mode)
                    installer_fn(
                        name=config.name,
                        version=config.version,
                        prefix=config.prefix,
                        passthrough_args=config.passthrough_args,
                    )
                else:
                    msg = (
                        f"No Python installer for '{config.name}'"
                        f" ({config.platform}/{config.mode})."
                    )
                    raise FileNotFoundError(msg)
    except Exception:
        if config.prefix and os.path.isdir(config.prefix):
            shutil.rmtree(config.prefix, ignore_errors=True)
        raise
    finally:
        os.chdir(orig_cwd)
        shutil.rmtree(tmp_dir, ignore_errors=True)
    # -- Post-install: linking ------------------------------------------------
    try:
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
            link_in_bash_completions(config.prefix)
            link_in_fish_completions(config.prefix)
            link_in_zsh_completions(config.prefix)
            if config.push:
                push_app_build(config.name)
        elif config.mode == "system":
            if config.update_ldconfig:
                _run("ldconfig", sudo=True, check=False)
    except Exception:
        opt_link = os.path.join(_opt_prefix(), config.name)
        if os.path.islink(opt_link):
            os.unlink(opt_link)
        if config.prefix and os.path.isdir(config.prefix):
            shutil.rmtree(config.prefix, ignore_errors=True)
        raise
    # -- Post-install: success marker ------------------------------------------
    # Written after linking so a failed link = failed install = retried.
    if config.prefix:
        install_dir = os.path.join(config.prefix, ".install")
        os.makedirs(install_dir, exist_ok=True)
        revision = _app_json_revision(config.name)
        if revision > 0:
            with open(os.path.join(install_dir, "revision"), "w") as f:
                f.write(str(revision))
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
    from koopa.download import download

    tarball_path = f"{parent_name}/{package_name}-{version}.tar.{compress_ext}"
    url = f"{mirror}/{tarball_path}"
    try:
        tarball = download(url)
        if not is_valid_archive(tarball):
            raise OSError(f"Downloaded file is not a valid archive: '{tarball}'")
    except (subprocess.CalledProcessError, OSError):
        _mirror_fallbacks = {
            "https://ftpmirror.gnu.org": "https://ftp.gnu.org/gnu",
            "https://download.savannah.nongnu.org/releases": "https://download-mirror.savannah.gnu.org/releases",
        }
        fallback_base = _mirror_fallbacks.get(mirror)
        if fallback_base:
            fallback = f"{fallback_base}/{tarball_path}"
            print(
                f"Mirror failed, retrying from '{fallback}'.",
                file=sys.stderr,
            )
            tarball = download(fallback)
        else:
            raise
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
    from koopa.build import activate_app

    env = activate_app("go", build_only=True)
    env.apply()
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
    _link_pip_binaries(
        egg_name=egg_name,
        version=version,
        prefix=prefix,
        libexec=libexec,
    )


def _link_pip_binaries(
    *,
    egg_name: str,
    version: str,
    prefix: str,
    libexec: str,
) -> None:
    """Link binaries from pip venv into prefix/bin using RECORD metadata."""
    import glob as glob_mod
    import re

    venv_python = os.path.join(libexec, "bin", "python3")
    result = subprocess.run(
        [venv_python, "--version"],
        capture_output=True,
        text=True,
        check=True,
    )
    py_version = result.stdout.strip().split()[-1]
    py_maj_min = ".".join(py_version.split(".")[:2])
    record_pattern = os.path.join(
        libexec,
        "lib",
        f"python{py_maj_min}",
        "site-packages",
        f"{egg_name}-{version}*.dist-info",
        "RECORD",
    )
    matches = glob_mod.glob(record_pattern)
    if not matches:
        record_pattern2 = os.path.join(
            libexec,
            "lib",
            f"python{py_maj_min}",
            "site-packages",
            f"{egg_name}-*.dist-info",
            "RECORD",
        )
        matches = glob_mod.glob(record_pattern2)
    if not matches:
        msg = f"No RECORD file found for {egg_name} in {libexec}"
        raise FileNotFoundError(msg)
    record_file = matches[0]
    bin_pattern = re.compile(r"^\.\./\.\./\.\./bin/([^/,]+),")
    man1_pattern = re.compile(r"^\.\./\.\./\.\./share/man/man1/([^/,]+),")
    bin_names: list[str] = []
    man1_names: list[str] = []
    with open(record_file) as fh:
        for line in fh:
            m = bin_pattern.match(line)
            if m:
                bin_names.append(m.group(1))
                continue
            m = man1_pattern.match(line)
            if m:
                man1_names.append(m.group(1))
    if not bin_names:
        msg = f"No binaries found in RECORD: {record_file}"
        raise RuntimeError(msg)
    libexec_bin = os.path.join(libexec, "bin")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    for bin_name in bin_names:
        src = os.path.join(libexec_bin, bin_name)
        if not os.path.isfile(src):
            continue
        dst = os.path.join(bin_dir, bin_name)
        if os.path.islink(dst):
            os.unlink(dst)
        os.symlink(src, dst)
    if man1_names:
        man1_src_dir = os.path.join(libexec, "share", "man", "man1")
        man1_dst_dir = os.path.join(prefix, "share", "man", "man1")
        for man1_name in man1_names:
            src = os.path.join(man1_src_dir, man1_name)
            if not os.path.isfile(src):
                continue
            os.makedirs(man1_dst_dir, exist_ok=True)
            dst = os.path.join(man1_dst_dir, man1_name)
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


# -- Install lock -------------------------------------------------------------


def _install_lock_path() -> str:
    cache_dir = os.path.join(
        os.environ.get(
            "XDG_CACHE_HOME",
            os.path.join(os.path.expanduser("~"), ".cache"),
        ),
        "koopa",
    )
    return os.path.join(cache_dir, "install.lock")


def _acquire_install_lock() -> bool:
    """Acquire the install lock. Returns True if newly acquired, False if already held."""
    path = _install_lock_path()
    if os.path.isfile(path):
        try:
            pid = int(Path(path).read_text().strip())
            if pid == os.getpid():
                return False
            os.kill(pid, 0)
            msg = (
                f"Another install process is running (PID {pid}). "
                "Wait for it to finish or remove "
                f"'{path}' if the process is stale."
            )
            raise RuntimeError(msg)
        except (ValueError, ProcessLookupError):
            pass
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Path(path).write_text(str(os.getpid()))
    return True


def _release_install_lock() -> None:
    path = _install_lock_path()
    try:
        if os.path.isfile(path):
            pid = int(Path(path).read_text().strip())
            if pid == os.getpid():
                os.unlink(path)
    except (ValueError, OSError):
        pass


# -- Conda package installer --------------------------------------------------

_CONDA_OVERRIDE_TTL = 86400
_conda_use_override_channels: bool | None = None


def _conda_override_cache_path() -> str:
    cache_dir = os.path.join(
        os.environ.get(
            "XDG_CACHE_HOME",
            os.path.join(os.path.expanduser("~"), ".cache"),
        ),
        "koopa",
    )
    return os.path.join(cache_dir, "conda-override-channels")


def _conda_should_override() -> bool:
    global _conda_use_override_channels  # noqa: PLW0603
    if _conda_use_override_channels is not None:
        return _conda_use_override_channels
    path = _conda_override_cache_path()
    if os.path.isfile(path):
        import time

        age = time.time() - os.path.getmtime(path)
        if age < _CONDA_OVERRIDE_TTL:
            _conda_use_override_channels = True
            return True
        os.unlink(path)
    _conda_use_override_channels = False
    return False


def _conda_set_override() -> None:
    global _conda_use_override_channels  # noqa: PLW0603
    _conda_use_override_channels = True
    path = _conda_override_cache_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Path(path).touch()


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
    pkg_spec = f"--file={yaml_file}" if yaml_file else f"{name}=={version}"
    if _conda_should_override():
        create_args = [
            conda,
            "create",
            "--yes",
            f"--prefix={libexec}",
            "--channel=conda-forge",
            "--channel=bioconda",
            "--override-channels",
            pkg_spec,
        ]
        subprocess.run(create_args, check=True)
    else:
        create_args = [conda, "create", "--yes", f"--prefix={libexec}"]
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
        create_args.append(pkg_spec)
        result = subprocess.run(create_args, check=False)
        if result.returncode != 0:
            print(
                "Retrying with conda-forge/bioconda channels directly.",
                file=sys.stderr,
            )
            _conda_set_override()
            fallback_args = [
                conda,
                "create",
                "--yes",
                f"--prefix={libexec}",
                "--channel=conda-forge",
                "--channel=bioconda",
                "--override-channels",
                pkg_spec,
            ]
            subprocess.run(fallback_args, check=True)
    _link_conda_binaries(name=name, version=version, prefix=prefix, libexec=libexec)


def _link_conda_binaries(
    *,
    name: str,
    version: str,
    prefix: str,
    libexec: str,
) -> None:
    """Link binaries from conda env into prefix/bin using conda metadata."""
    import glob as glob_mod

    from koopa.io import extract_conda_bin_names

    conda_meta = os.path.join(libexec, "conda-meta")
    json_pattern = f"{name}-{version}-*.json"
    if name == "snakemake":
        json_pattern = "snakemake-minimal-*.json"
    matches = glob_mod.glob(os.path.join(conda_meta, json_pattern))
    if not matches:
        matches = glob_mod.glob(os.path.join(conda_meta, f"{name}-*.json"))
    if not matches:
        msg = f"No conda metadata found for {name} in {conda_meta}"
        raise FileNotFoundError(msg)
    json_file = matches[0]
    bin_names = extract_conda_bin_names(json_file)
    if not bin_names:
        msg = f"No binaries found in conda metadata: {json_file}"
        raise RuntimeError(msg)
    libexec_bin = os.path.join(libexec, "bin")
    bin_dir = os.path.join(prefix, "bin")
    man1_src_dir = os.path.join(libexec, "share", "man", "man1")
    man1_dst_dir = os.path.join(prefix, "share", "man", "man1")
    os.makedirs(bin_dir, exist_ok=True)
    for bin_name in bin_names:
        src = os.path.join(libexec_bin, bin_name)
        if not os.path.isfile(src):
            msg = f"Binary does not exist: {src!r}"
            raise FileNotFoundError(msg)
        dst = os.path.join(bin_dir, bin_name)
        if os.path.islink(dst):
            os.unlink(dst)
        os.symlink(src, dst)
        man1_src = os.path.join(man1_src_dir, f"{bin_name}.1")
        if os.path.isfile(man1_src):
            os.makedirs(man1_dst_dir, exist_ok=True)
            man1_dst = os.path.join(man1_dst_dir, f"{bin_name}.1")
            if os.path.islink(man1_dst):
                os.unlink(man1_dst)
            os.symlink(man1_src, man1_dst)


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


def install_missing_default_apps(*, verbose: bool = False) -> None:
    """Install any default apps that are not yet present."""
    from koopa.alert import alert, alert_success
    from koopa.app import shared_apps

    if not is_owner():
        return
    app_names = shared_apps(mode="default")
    opt = _opt_prefix()
    missing = [a for a in app_names if not os.path.exists(os.path.join(opt, a))]
    if not missing:
        return
    n = len(missing)
    label = "app" if n == 1 else "apps"
    alert(f"Installing {n} missing default {label}: {', '.join(missing)}")
    for app in missing:
        cli_install(app, verbose=verbose)
    alert_success("All missing default apps installed.")


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
            if any(os.path.isdir(os.path.join(app_prefix, v, ".install")) for v in versions):
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
    result = git_pull(prefix, capture=True)
    stdout = (result.stdout or "").strip() if result else ""
    if "Already up to date" in stdout:
        alert_note("koopa is already up to date.")
    elif stdout:
        print(stdout, file=sys.stderr)
    _zsh_compaudit_set_permissions()


def _update_venv(prefix: str) -> None:
    """Create or update the Python virtual environment with extras."""
    from koopa.alert import alert, warn

    python_version_file = os.path.join(prefix, ".python-version")
    if not os.path.isfile(python_version_file):
        return
    if not is_owner():
        return
    with open(python_version_file) as f:
        python_version = f.read().strip()
    venv_dir = os.path.join(prefix, ".venv")
    if os.path.isdir(venv_dir):
        pyvenv_cfg = os.path.join(venv_dir, "pyvenv.cfg")
        if os.path.isfile(pyvenv_cfg):
            venv_version = ""
            with open(pyvenv_cfg) as f:
                for line in f:
                    key, _, value = line.partition("=")
                    key = key.strip()
                    if key in ("version", "version_info"):
                        full_ver = value.strip()
                        venv_version = ".".join(full_ver.split(".")[:2])
                        break
            if venv_version and venv_version != python_version:
                alert(
                    "Python version changed"
                    f" ({venv_version} -> {python_version})."
                    " Recreating virtual environment."
                )
                shutil.rmtree(venv_dir)
    if not os.path.isdir(venv_dir):
        alert("Creating Python virtual environment.")
        try:
            import venv

            venv.create(venv_dir, with_pip=True, symlinks=True)
        except Exception as exc:
            warn(
                f"Failed to create virtual environment: {exc}\n"
                f"  Run bootstrap to install Python {python_version}:\n"
                f"    sh '{os.path.join(prefix, 'lang', 'sh', 'include', 'bootstrap.sh')}'"
            )
            if os.path.isdir(venv_dir):
                shutil.rmtree(venv_dir)
            return
    venv_python = os.path.join(venv_dir, "bin", "python3")
    if not os.path.isfile(venv_python):
        warn(
            f"Virtual environment python not found at '{venv_python}'.\n"
            f"  Run bootstrap to install Python {python_version}:\n"
            f"    sh '{os.path.join(prefix, 'lang', 'sh', 'include', 'bootstrap.sh')}'"
        )
        if os.path.isdir(venv_dir):
            shutil.rmtree(venv_dir)
        return
    stamp_file = os.path.join(venv_dir, ".stamp")
    dep_files = [
        os.path.join(prefix, "pyproject.toml"),
    ]
    if os.path.isfile(stamp_file):
        stamp_mtime = os.path.getmtime(stamp_file)
        if all(os.path.getmtime(f) <= stamp_mtime for f in dep_files if os.path.isfile(f)):
            return
    alert("Installing koopa Python package.")
    if not os.path.isfile(os.path.join(venv_dir, "bin", "pip3")):
        alert("Installing pip into virtual environment.")
        subprocess.run(
            [venv_python, "-m", "ensurepip", "--upgrade"],
            check=True,
        )
    subprocess.run(
        [
            venv_python,
            "-m",
            "pip",
            "install",
            "--editable",
            f"{prefix}[extra]",
            "--upgrade",
            "--quiet",
        ],
        check=True,
    )
    with open(stamp_file, "w") as f:
        f.write("")


# -- Update pipeline ----------------------------------------------------------


def update_bootstrap(*, verbose: bool = False) -> bool:
    """Update bootstrap if out of date.

    Returns True if bootstrap was rebuilt, False if already current.
    """
    from koopa.alert import alert, warn
    from koopa.check import check_bootstrap_version
    from koopa.prefix import bootstrap_prefix

    bp = bootstrap_prefix()
    bootstrap_absent = not os.path.isdir(bp)
    system_python_adequate = sys.version_info >= (3, 12)

    # If bootstrap is absent and system Python is adequate, nothing to do.
    if bootstrap_absent and system_python_adequate:
        return False
    # If bootstrap is present and up to date, also verify Python version matches.
    if not bootstrap_absent and check_bootstrap_version():
        from koopa.prefix import koopa_prefix

        python_version_file = os.path.join(koopa_prefix(), ".python-version")
        if os.path.isfile(python_version_file):
            with open(python_version_file) as _f:
                desired_version = _f.read().strip()
            bootstrap_python = os.path.join(bp, "bin", "python3")
            if os.path.isfile(bootstrap_python):
                _res = subprocess.run(
                    [bootstrap_python, "--version"],
                    capture_output=True,
                    text=True,
                )
                if _res.returncode == 0:
                    actual = _res.stdout.strip().split()[-1]
                    actual_minor = ".".join(actual.split(".")[:2])
                    if actual_minor == desired_version:
                        return False
                    # Python version mismatch — fall through to rebuild
            else:
                return False
        else:
            return False
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
        return False
    return True


def _is_supported_app(name: str) -> bool:
    """Check if an app is supported on the current platform."""
    from koopa.os import os_id

    json_data = _import_app_json()
    entry = json_data.get(name, {})
    if not isinstance(entry, dict):
        return False
    supported = entry.get("supported", {})
    current_os = os_id()
    return not (current_os in supported and not supported[current_os])


def update_stale_apps(*, verbose: bool = False) -> None:
    """Find and reinstall all outdated or broken shared apps."""
    from koopa.alert import alert, alert_success
    from koopa.check import broken_app_installs, outdated_apps

    if not is_owner():
        return
    outdated = outdated_apps()
    broken = broken_app_installs()
    apps = list(dict.fromkeys(outdated + broken))
    apps = [a for a in apps if _is_supported_app(a)]
    if not apps:
        alert_success("All installed apps are up to date.")
        return
    n = len(apps)
    label = "app" if n == 1 else "apps"
    alert(f"Updating {n} {label}: {', '.join(apps)}")
    for app in apps:
        cli_install(app, reinstall=True, verbose=verbose)
    _update_stale_revdeps(apps, failed=[], verbose=verbose)
    alert_success("All stale apps updated successfully.")


def _update_stale_revdeps(
    updated_apps: list[str],
    *,
    failed: list[str],
    verbose: bool = False,
) -> None:
    """Log reverse dependencies of updated apps (informational only).

    Reverse dependencies are not automatically rebuilt because shared library
    updates typically remain ABI-compatible and the opt/ symlinks ensure apps
    resolve to the new version. Use ``koopa reinstall --with-revdeps`` to
    explicitly rebuild if needed.
    """
    from koopa.alert import alert_note
    from koopa.app import stale_revdeps

    succeeded = [a for a in updated_apps if a not in failed]
    if not succeeded:
        return
    revdeps = stale_revdeps(succeeded)
    revdeps = [r for r in revdeps if r not in updated_apps and r not in failed]
    if not revdeps:
        return
    n_revdeps = len(revdeps)
    label_revdeps = "reverse dependency" if n_revdeps == 1 else "reverse dependencies"
    alert_note(
        f"{n_revdeps} {label_revdeps} may need rebuilding: {', '.join(revdeps)}\n"
        "  Run 'koopa reinstall --with-revdeps <app>' to rebuild if needed.",
    )


def remove_unsupported_apps(*, verbose: bool = False) -> None:
    """Remove installed apps that are no longer in app.json or marked removed."""
    from koopa.alert import alert
    from koopa.check import unsupported_apps
    from koopa.uninstall import UninstallConfig, uninstall_app

    if not is_owner():
        return
    apps = unsupported_apps()
    if not apps:
        return
    n_unsupported = len(apps)
    label_unsupported = "app" if n_unsupported == 1 else "apps"
    alert(f"Removing {n_unsupported} unsupported {label_unsupported}: {', '.join(apps)}")
    for app in apps:
        config = UninstallConfig(name=app, verbose=verbose)
        uninstall_app(config)


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
    n_user = len(apps)
    label_user = "app" if n_user == 1 else "apps"
    alert(f"Updating {n_user} user {label_user}: {', '.join(apps)}")
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


def fetch_user_repos() -> None:
    """Pull latest changes for user git repos if they exist."""
    from koopa.alert import alert_note, warn
    from koopa.git import git_pull, is_git_repo

    home = os.path.expanduser("~")
    repos = [
        os.path.join(home, ".config", "koopa", "dotfiles-work"),
        os.path.join(home, ".config", "koopa", "dotfiles-private"),
        os.path.join(home, "scripts-private"),
    ]
    for repo in repos:
        if not os.path.isdir(repo) or not is_git_repo(repo):
            continue
        name = os.path.basename(repo)
        alert_note(f"Pulling user repo '{name}'.")
        try:
            git_pull(repo)
        except Exception as exc:
            warn(f"Failed to pull '{name}': {exc}")


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


def _build_passthrough_args(name: str) -> list[str]:
    """Build passthrough args from app.json installer_args."""
    data = _import_app_json()
    entry = data.get(name, {})
    installer_args = entry.get("installer_args", {}) if isinstance(entry, dict) else {}
    if not installer_args:
        return []
    result: list[str] = []
    for key, value in installer_args.items():
        flag = key.replace("_", "-")
        if isinstance(value, list):
            for item in value:
                result.append(f"--{flag}={item}")
        else:
            result.append(f"--{flag}={value}")
    return result


def cli_install(
    name: str,
    *,
    reinstall: bool = False,
    verbose: bool = False,
) -> None:
    """High-level CLI entry point for installing an app by name.

    This is the Python equivalent of ``koopa install <name>``.
    """
    acquired = _acquire_install_lock()
    try:
        config = InstallConfig(
            name=name,
            reinstall=reinstall,
            verbose=verbose,
            binary=_can_install_binary(),
            push=_can_push_binary(),
            passthrough_args=_build_passthrough_args(name),
        )
        install_app(config)
    finally:
        if acquired:
            _release_install_lock()
