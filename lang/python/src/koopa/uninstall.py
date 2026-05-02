"""Application uninstallation functions.

Provides ``uninstall_app`` — the Python equivalent of the Bash function
``_koopa_uninstall_app``. Removes an app's versioned prefix directory
and its symlinks from bin/, opt/, and man1/.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

from koopa.uninstallers import get_python_uninstaller, has_python_uninstaller


def _koopa_prefix() -> str:
    """Return koopa installation prefix."""
    return os.environ.get("KOOPA_PREFIX", str(Path(__file__).resolve().parents[4]))


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


def _is_owner() -> bool:
    """Check if current user is the koopa installation owner."""
    try:
        return os.stat(_koopa_prefix()).st_uid == os.getuid()
    except OSError:
        return False


def _is_admin() -> bool:
    """Check if current user has admin/root access."""
    return os.getuid() == 0


def _import_app_json_bin(name: str) -> list[str]:
    """Get bin names for an app from app.json."""
    json_path = os.path.join(_koopa_prefix(), "etc", "koopa", "app.json")
    with open(json_path) as f:
        data = json.load(f)
    entry = data.get(name, {})
    if isinstance(entry, dict):
        bins = entry.get("bin", [])
        if isinstance(bins, str):
            return [bins]
        if isinstance(bins, list):
            return bins
    return []


def _import_app_json_man1(name: str) -> list[str]:
    """Get man1 page names for an app from app.json."""
    json_path = os.path.join(_koopa_prefix(), "etc", "koopa", "app.json")
    with open(json_path) as f:
        data = json.load(f)
    entry = data.get(name, {})
    if isinstance(entry, dict):
        man1 = entry.get("man1", [])
        if isinstance(man1, str):
            return [man1]
        if isinstance(man1, list):
            return man1
    return []


@dataclass
class UninstallConfig:
    """Configuration for application uninstallation."""

    name: str
    mode: str = "shared"
    prefix: str = ""
    platform: str = "common"
    uninstaller: str = ""
    verbose: bool = False
    quiet: bool = False
    unlink_in_bin: bool | None = None
    unlink_in_man1: bool | None = None
    unlink_in_opt: bool | None = None


def uninstall_app(config: UninstallConfig) -> None:
    """Uninstall an application.

    Removes the app's prefix directory and symlinks from bin/, opt/, and
    man1/. Optionally runs a custom uninstaller script if one exists.
    """
    if config.verbose:
        os.environ["KOOPA_VERBOSE"] = "1"
    app_dir = _app_prefix()
    if config.mode == "shared":
        if not _is_owner():
            msg = "Only the koopa owner can uninstall shared apps."
            raise PermissionError(msg)
        if not config.prefix:
            config.prefix = os.path.join(app_dir, config.name)
        if config.unlink_in_bin is None:
            config.unlink_in_bin = True
        if config.unlink_in_man1 is None:
            config.unlink_in_man1 = True
        if config.unlink_in_opt is None:
            config.unlink_in_opt = True
    elif config.mode == "system":
        if not _is_owner():
            msg = "Only the koopa owner can uninstall system apps."
            raise PermissionError(msg)
        if not _is_admin():
            msg = "Admin/root access required for system uninstalls."
            raise PermissionError(msg)
        config.unlink_in_bin = False
        config.unlink_in_man1 = False
        config.unlink_in_opt = False
    elif config.mode == "user":
        config.unlink_in_bin = False
        config.unlink_in_man1 = False
        config.unlink_in_opt = False
    if config.prefix and not os.path.isdir(config.prefix):
        if not config.quiet:
            print(
                f"'{config.name}' is not installed at '{config.prefix}'.",
                file=sys.stderr,
            )
        return
    if config.prefix:
        config.prefix = os.path.realpath(config.prefix)
    if not config.quiet:
        print(
            f"Uninstalling '{config.name}' at '{config.prefix}'.",
            file=sys.stderr,
        )
    uninstaller_bn = config.uninstaller or config.name
    if has_python_uninstaller(uninstaller_bn, config.platform, config.mode):
        uninstaller = get_python_uninstaller(uninstaller_bn, config.platform, config.mode)
        uninstaller(
            name=config.name,
            platform=config.platform,
            mode=config.mode,
            prefix=config.prefix,
            verbose=config.verbose,
        )
    else:
        uninstaller_file = os.path.join(
            _bash_prefix(),
            "include",
            "uninstall",
            config.platform,
            config.mode,
            f"{uninstaller_bn}.sh",
        )
        if os.path.isfile(uninstaller_file):
            _run_uninstaller_script(uninstaller_file, config)
    if os.path.isdir(config.prefix):
        if config.mode == "system":
            subprocess.run(
                ["sudo", "rm", "-rf", config.prefix],
                check=True,
            )
        else:
            shutil.rmtree(config.prefix, ignore_errors=True)
    if config.mode == "shared":
        if config.unlink_in_opt:
            _unlink_in_opt(config.name)
        if config.unlink_in_bin:
            bins = _import_app_json_bin(config.name)
            for b in bins:
                _unlink_in_bin(b)
        if config.unlink_in_man1:
            man1_names = _import_app_json_man1(config.name)
            for m in man1_names:
                _unlink_in_man1(m)
    if not config.quiet:
        print(
            f"Successfully uninstalled '{config.name}'.",
            file=sys.stderr,
        )


def _run_uninstaller_script(
    script_path: str,
    config: UninstallConfig,
) -> None:
    """Run a Bash uninstaller script in an isolated subshell."""
    bash = shutil.which("bash")
    if bash is None:
        return
    header_file = os.path.join(_bash_prefix(), "include", "header.sh")
    tmp_dir = tempfile.mkdtemp()
    try:
        parts = [
            f"source '{header_file}'",
            f"cd '{tmp_dir}'",
            f"source '{script_path}'",
            "main",
        ]
        if config.mode == "system":
            parts.insert(1, 'PATH="${PATH}:/usr/sbin:/sbin"')
        cmd = "; ".join(parts)
        env = os.environ.copy()
        env["KOOPA_INSTALL_NAME"] = config.name
        env["KOOPA_INSTALL_PREFIX"] = config.prefix
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
                cmd,
            ],
            env=env,
            check=False,
        )
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)


def _unlink_in_opt(name: str) -> None:
    """Remove symlink from koopa opt/ directory."""
    target = os.path.join(_opt_prefix(), name)
    if os.path.islink(target):
        os.unlink(target)


def _unlink_in_bin(name: str) -> None:
    """Remove symlink from koopa bin/ directory."""
    target = os.path.join(_bin_prefix(), name)
    if os.path.islink(target):
        os.unlink(target)


def _unlink_in_man1(name: str) -> None:
    """Remove symlink from koopa man1/ directory."""
    target = os.path.join(_man1_prefix(), name)
    if os.path.islink(target):
        os.unlink(target)


def _is_shared_install() -> bool:
    """Check if koopa is a shared (non-user-home) install."""
    home = os.path.expanduser("~")
    return not _koopa_prefix().startswith(home)


def uninstall_koopa() -> None:
    """Uninstall koopa itself."""
    kp = _koopa_prefix()
    bootstrap = os.path.join(kp, "bootstrap")
    config = os.path.join(kp, "etc", "koopa")
    if sys.stdin.isatty():
        answer = input("Proceed with koopa uninstall? [Y/n] ").strip().lower()
        if answer in ("n", "no"):
            return
    print("Removing bootstrap prefix.", file=sys.stderr)
    shutil.rmtree(bootstrap, ignore_errors=True)
    print("Removing config prefix.", file=sys.stderr)
    shutil.rmtree(config, ignore_errors=True)
    if _is_shared_install() and _is_admin():
        if sys.platform == "linux":
            profile_d = "/etc/profile.d/zzz-koopa.sh"
            if os.path.exists(profile_d):
                print(f"Removing {profile_d}.", file=sys.stderr)
                subprocess.run(["sudo", "rm", "-f", profile_d], check=True)
        print(f"Removing {kp}.", file=sys.stderr)
        subprocess.run(["sudo", "rm", "-rf", kp], check=True)
    else:
        print(f"Removing {kp}.", file=sys.stderr)
        shutil.rmtree(kp, ignore_errors=True)
