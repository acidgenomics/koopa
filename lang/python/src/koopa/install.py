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
import threading
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, BinaryIO, TextIO

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


def _bash_prefix() -> str:
    """Return koopa bash prefix."""
    return os.path.join(_koopa_prefix(), "lang", "bash")


def _cpu_count() -> int:
    """Return CPU count."""
    return os.cpu_count() or 1


def _is_owner() -> bool:
    """Check if current user is the koopa installation owner."""
    prefix = _koopa_prefix()
    try:
        return os.stat(prefix).st_uid == os.getuid()
    except OSError:
        return False


def _is_admin() -> bool:
    """Check if current user is an admin (root or sudo capable)."""
    return os.getuid() == 0


def _is_linux() -> bool:
    """Check if running on Linux."""
    return sys.platform == "linux"


def _is_macos() -> bool:
    """Check if running on macOS."""
    return sys.platform == "darwin"


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


def _is_lmod_active() -> bool:
    """Check if Lmod environment modules are active."""
    return "LMOD_DIR" in os.environ


def _os_string() -> str:
    """Get OS string for binary packages."""
    if _is_macos():
        return "macos"
    if _is_linux():
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


def _tmp_log_file() -> str:
    """Create a temporary log file."""
    fd, path = tempfile.mkstemp(suffix=".log", prefix="koopa-")
    os.close(fd)
    return path


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


def install_app_subshell(
    *,
    name: str,
    version: str = "",
    prefix: str = "",
    installer: str = "",
    platform: str = "common",
    mode: str = "shared",
    passthrough_args: list[str] | None = None,
) -> None:
    """Install an application in a hardened subshell.

    Sources the installer script and invokes its ``main`` function inside
    a subprocess with restricted environment.
    """
    if not installer:
        installer = name
    installer_file = os.path.join(
        _bash_prefix(),
        "include",
        "install",
        platform,
        mode,
        f"{installer}.sh",
    )
    if not os.path.isfile(installer_file):
        msg = f"Installer file not found: {installer_file}"
        raise FileNotFoundError(msg)
    tmp_dir = tempfile.mkdtemp(prefix="koopa-install-")
    try:
        env = os.environ.copy()
        env["KOOPA_INSTALL_NAME"] = name
        env["KOOPA_INSTALL_PREFIX"] = prefix
        env["KOOPA_INSTALL_VERSION"] = version
        header_file = os.path.join(_bash_prefix(), "include", "header.sh")
        passthrough_str = ""
        if passthrough_args:
            passthrough_str = " ".join(passthrough_args)
        cmd_str = f"source '{header_file}'; source '{installer_file}'; main {passthrough_str}"
        bash = shutil.which("bash")
        if bash is None:
            msg = "bash not found."
            raise FileNotFoundError(msg)
        subprocess.run(
            [
                bash,
                "--noprofile",
                "--norc",
                "-o",
                "errexit",
                "-o",
                "errtrace",
                "-o",
                "nounset",
                "-o",
                "pipefail",
                "-c",
                cmd_str,
            ],
            cwd=tmp_dir,
            env=env,
            check=True,
        )
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


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
    tar_file = tempfile.mktemp(suffix=".tar.gz", prefix="koopa-push-")
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
        if not _is_owner():
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
        if not _is_owner():
            msg = "Only the koopa owner can install system apps."
            raise PermissionError(msg)
        if not _is_admin():
            msg = "Admin/root access is required for system installs."
            raise PermissionError(msg)
        config.isolate = False
        config.link_in_bin = False
        config.link_in_man1 = False
        config.link_in_opt = False
        config.prefix_check = False
        config.push = False
        if _is_linux():
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
        stdout_log = os.path.join(config.prefix, ".koopa-install-stdout.log")
        if not os.path.isfile(stdout_log):
            config.reinstall = True
        if config.reinstall:
            if not config.quiet:
                print(
                    f"Uninstalling '{config.name}' at '{config.prefix}'.",
                    file=sys.stderr,
                )
            if config.mode == "system":
                _run("rm", "-rf", config.prefix, sudo=True)
            else:
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
                dep_prefix = os.path.join(app_dir, dep)
                if os.path.isdir(dep_prefix):
                    continue
                dep_config = InstallConfig(name=dep)
                if config.bootstrap:
                    dep_config.bootstrap = True
                if config.verbose:
                    dep_config.verbose = True
                install_app(dep_config)
    # -- Start install --------------------------------------------------------
    if not config.quiet:
        print(
            f"Installing '{config.name}' at '{config.prefix}'.",
            file=sys.stderr,
        )
    # Create prefix directory.
    if config.prefix and not os.path.isdir(config.prefix):
        if config.mode == "system":
            _run("mkdir", "-p", config.prefix, sudo=True)
        else:
            os.makedirs(config.prefix, exist_ok=True)
    # -- Dispatch to installer ------------------------------------------------
    if config.binary:
        if config.mode != "shared" or not config.prefix:
            msg = "Binary install requires shared mode and a prefix."
            raise RuntimeError(msg)
        install_app_from_binary_package(config.prefix)
    elif not config.isolate:
        os.environ["KOOPA_INSTALL_APP_SUBSHELL"] = "1"
        try:
            install_app_subshell(
                name=config.name,
                version=config.version,
                prefix=config.prefix,
                installer=config.installer,
                platform=config.platform,
                mode=config.mode,
                passthrough_args=config.passthrough_args,
            )
        finally:
            os.environ.pop("KOOPA_INSTALL_APP_SUBSHELL", None)
    else:
        # Isolated subshell with clean environment.
        stdout_file = _tmp_log_file()
        stderr_file = _tmp_log_file()
        try:
            _run_isolated_subshell(
                config=config,
                stdout_file=stdout_file,
                stderr_file=stderr_file,
            )
            # Copy log files into prefix.
            if config.mode == "shared" and os.path.isdir(config.prefix):
                config.copy_log_files = True
            if config.copy_log_files and os.path.isdir(config.prefix):
                shutil.copy2(
                    stdout_file,
                    os.path.join(config.prefix, ".koopa-install-stdout.log"),
                )
                shutil.copy2(
                    stderr_file,
                    os.path.join(config.prefix, ".koopa-install-stderr.log"),
                )
        finally:
            for f in (stdout_file, stderr_file):
                if os.path.isfile(f):
                    os.unlink(f)
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
        print(
            f"Successfully installed '{config.name}' at '{config.prefix}'.",
            file=sys.stderr,
        )


# -- Isolated subshell runner -------------------------------------------------


def _run_isolated_subshell(
    *,
    config: InstallConfig,
    stdout_file: str,
    stderr_file: str,
) -> None:
    """Run the installer in an isolated subshell with clean environment.

    Constructs a minimal environment and invokes bash with the installer
    sourced inside it, capturing stdout and stderr to log files.
    """
    # Locate executables.
    if config.bootstrap:
        bootstrap_prefix = os.environ.get("KOOPA_BOOTSTRAP_PREFIX", "")
        bash = os.path.join(bootstrap_prefix, "bin", "bash")
    else:
        bash = shutil.which("bash") or "/usr/bin/bash"
    env_bin = shutil.which("env") or "/usr/bin/env"
    # Build environment variables.
    env_vars: dict[str, str] = {}
    if config.inherit_env or _is_lmod_active():
        env_vars["PATH"] = os.environ.get("PATH", "")
        for var in (
            "CC",
            "CPLUS_INCLUDE_PATH",
            "CXX",
            "C_INCLUDE_PATH",
            "F77",
            "FC",
            "INCLUDE",
            "LD_LIBRARY_PATH",
            "LIBRARY_PATH",
            "CPATH",
            "PKG_CONFIG_PATH",
        ):
            val = os.environ.get(var, "")
            if val:
                env_vars[var] = val
    else:
        env_vars["PATH"] = "/usr/bin:/usr/sbin:/bin:/sbin"
    env_vars.update(
        {
            "HOME": os.environ.get("HOME", ""),
            "KOOPA_ACTIVATE": "0",
            "KOOPA_CPU_COUNT": str(_cpu_count()),
            "KOOPA_INSTALL_APP_SUBSHELL": "1",
            "KOOPA_VERBOSE": "1" if config.verbose else "0",
            "LANG": "C",
            "LC_ALL": "C",
            "PWD": os.environ.get("HOME", ""),
            "TMPDIR": os.environ.get("TMPDIR", "/tmp"),
        }
    )
    # Forward optional env vars.
    for var in (
        "KOOPA_CAN_INSTALL_BINARY",
        "AWS_CA_BUNDLE",
        "DEFAULT_CA_BUNDLE_PATH",
        "NODE_EXTRA_CA_CERTS",
        "REQUESTS_CA_BUNDLE",
        "SSL_CERT_FILE",
        "HTTP_PROXY",
        "HTTPS_PROXY",
        "http_proxy",
        "https_proxy",
        "GOPROXY",
    ):
        val = os.environ.get(var)
        if val:
            env_vars[var] = val
    header_file = os.path.join(_bash_prefix(), "include", "header.sh")
    installer = config.installer or config.name
    os.path.join(
        _bash_prefix(),
        "include",
        "install",
        config.platform,
        config.mode,
        f"{installer}.sh",
    )
    passthrough = ""
    if config.passthrough_args:
        passthrough = " ".join(config.passthrough_args)
    bash_cmd = (
        f"source '{header_file}'; "
        f"koopa_install_app_subshell "
        f"--installer={installer} "
        f"--mode={config.mode} "
        f"--name={config.name} "
        f"--platform={config.platform} "
        f"--prefix={config.prefix} "
        f"--version={config.version} "
        f"{passthrough}"
    )
    bash_args = [
        "--noprofile",
        "--norc",
        "-o",
        "errexit",
        "-o",
        "errtrace",
        "-o",
        "nounset",
        "-o",
        "pipefail",
    ]
    if config.verbose:
        bash_args.extend(["-o", "verbose"])
    # Use tee to capture output to log files while also printing.
    with (
        open(stdout_file, "w") as stdout_fh,
        open(stderr_file, "w") as stderr_fh,
    ):
        process = subprocess.Popen(
            [env_bin, "-i"]
            + [f"{k}={v}" for k, v in env_vars.items()]
            + [bash]
            + bash_args
            + ["-c", bash_cmd],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        def _tee_stream(
            in_stream: BinaryIO,
            out_stream: TextIO,
            log_fh: TextIO,
        ) -> None:
            """Tee a stream to both a file and another stream."""
            for line_bytes in in_stream:
                line = (
                    line_bytes.decode("utf-8", errors="replace")
                    if isinstance(line_bytes, bytes)
                    else line_bytes
                )
                out_stream.write(line)
                out_stream.flush()
                log_fh.write(line)
                log_fh.flush()

        t_out = threading.Thread(
            target=_tee_stream,
            args=(process.stdout, sys.stdout, stdout_fh),
        )
        t_err = threading.Thread(
            target=_tee_stream,
            args=(process.stderr, sys.stderr, stderr_fh),
        )
        t_out.start()
        t_err.start()
        t_out.join()
        t_err.join()
        returncode = process.wait()
    if returncode != 0:
        msg = f"Installation of '{config.name}' failed with exit code {returncode}."
        raise subprocess.CalledProcessError(returncode, bash_cmd, msg)


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
    bundle = shutil.which("bundle")
    ruby = shutil.which("ruby")
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
            f"--path={bin_dir}",
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
    """Install all supported apps.

    Converted from install-all-apps.sh.
    """
    install_shared_apps(all_apps=True)


def install_default_apps() -> None:
    """Install default apps.

    Converted from install-default-apps.sh.
    """
    install_shared_apps()


def install_shared_apps(
    *,
    all_apps: bool = False,
    update: bool = False,
) -> None:
    """Build and install multiple shared apps from source.

    Converted from install-shared-apps.sh.
    """
    if not _is_owner():
        msg = "Only the koopa owner can install shared apps."
        raise PermissionError(msg)
    if _is_macos() and _arch2() == "amd64":
        msg = "No longer supported for Intel Macs."
        raise RuntimeError(msg)
    try:
        import psutil  # noqa: PLC0415
        mem_gb = psutil.virtual_memory().total / (1024**3)
        mem_gb_cutoff = 6
        if mem_gb < mem_gb_cutoff:
            msg = f"{mem_gb_cutoff} GB of RAM is required."
            raise RuntimeError(msg)
    except ImportError:
        pass
    # Get app names from app.json.
    data = _import_app_json()
    if all_apps:
        app_names = sorted(data.keys())
    else:
        app_names = [
            k for k, v in sorted(data.items()) if isinstance(v, dict) and v.get("default", False)
        ]
    app_dir = _app_prefix()
    for app_name in app_names:
        app_prefix = os.path.join(app_dir, app_name)
        # Skip if already fully installed (has log file in some version).
        if os.path.isdir(app_prefix):
            versions = [
                d for d in os.listdir(app_prefix) if os.path.isdir(os.path.join(app_prefix, d))
            ]
            if any(
                os.path.isfile(
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


def install_koopa(  # noqa: PLR0912, PLR0915
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
    if _is_admin():
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
        if not _is_admin():
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
    if bootstrap:
        cli_install("bash", bootstrap=True)
        cli_install("coreutils", bootstrap=True)


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
