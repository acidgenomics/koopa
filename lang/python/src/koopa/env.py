"""Environment activation and export functions.

Converted from Bash activate and export functions.
"""

from __future__ import annotations

import contextlib
import os
import shutil
import subprocess

from koopa.prefix import julia_packages_prefix, pipx_prefix
from koopa.system import color_mode, cpu_count
from koopa.xdg import (
    xdg_cache_home,
    xdg_config_home,
    xdg_data_home,
    xdg_state_home,
)


def export_editor() -> None:
    """Set EDITOR environment variable."""
    for editor in ("nvim", "vim", "vi", "nano"):
        if shutil.which(editor):
            os.environ["EDITOR"] = editor
            os.environ["VISUAL"] = editor
            return


def export_gnupg() -> None:
    """Configure GnuPG environment."""
    gnupg_home = os.path.expanduser("~/.gnupg")
    os.environ["GNUPGHOME"] = gnupg_home
    os.makedirs(gnupg_home, mode=0o700, exist_ok=True)


def export_history() -> None:
    """Configure shell history settings."""
    os.environ["HISTSIZE"] = "100000"
    os.environ["SAVEHIST"] = "100000"
    os.environ.setdefault("HISTFILE", os.path.expanduser("~/.bash_history"))


def export_home() -> None:
    """Ensure HOME is set."""
    os.environ.setdefault("HOME", os.path.expanduser("~"))


def export_koopa_cpu_count() -> None:
    """Export KOOPA_CPU_COUNT."""
    os.environ["KOOPA_CPU_COUNT"] = str(cpu_count())


def export_koopa_shell() -> None:
    """Export KOOPA_SHELL."""
    shell = os.environ.get("SHELL", "/bin/sh")
    os.environ["KOOPA_SHELL"] = shell


def export_pager() -> None:
    """Set PAGER environment variable."""
    for pager in ("less", "more"):
        if shutil.which(pager):
            os.environ["PAGER"] = pager
            return


def export_manpager() -> None:
    """Set MANPAGER for colored man pages."""
    if shutil.which("less"):
        os.environ["MANPAGER"] = "less -R"


def activate_xdg() -> None:
    """Activate XDG base directory variables."""
    os.environ.setdefault("XDG_CACHE_HOME", xdg_cache_home())
    os.environ.setdefault("XDG_CONFIG_HOME", xdg_config_home())
    os.environ.setdefault("XDG_DATA_HOME", xdg_data_home())
    os.environ.setdefault("XDG_STATE_HOME", xdg_state_home())


def activate_color_mode() -> None:
    """Activate color mode detection."""
    os.environ["KOOPA_COLOR_MODE"] = color_mode()


def activate_gcc_colors() -> None:
    """Activate GCC colored diagnostics."""
    os.environ["GCC_COLORS"] = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"


def activate_python() -> None:
    """Activate Python environment settings."""
    os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
    os.environ.setdefault("PYTHONUNBUFFERED", "1")


def activate_pyright() -> None:
    """Activate Pyright environment settings."""
    os.environ.setdefault("PYRIGHT_PYTHON_FORCE_VERSION", "latest")


def activate_julia() -> None:
    """Activate Julia environment settings."""
    os.environ.setdefault("JULIA_DEPOT_PATH", julia_packages_prefix())


def activate_fzf() -> None:
    """Activate fzf settings."""
    os.environ.setdefault(
        "FZF_DEFAULT_OPTS",
        "--border --height=50% --info=inline --layout=reverse --tabstop=4",
    )
    if shutil.which("fd"):
        os.environ.setdefault("FZF_DEFAULT_COMMAND", "fd --type f --hidden")


def activate_micromamba() -> None:
    """Activate micromamba settings."""
    os.environ.setdefault("MAMBA_NO_BANNER", "1")


def activate_ripgrep() -> None:
    """Activate ripgrep config."""
    config = os.path.expanduser("~/.config/ripgrep/config")
    if os.path.isfile(config):
        os.environ["RIPGREP_CONFIG_PATH"] = config


def activate_tealdeer() -> None:
    """Activate tealdeer config."""
    config = os.path.expanduser("~/.config/tealdeer/config.toml")
    if os.path.isfile(config):
        os.environ["TEALDEER_CONFIG_DIR"] = os.path.dirname(config)


def activate_difftastic() -> None:
    """Activate difftastic."""
    if shutil.which("difft"):
        os.environ.setdefault("GIT_EXTERNAL_DIFF", "difft")


def activate_pipx() -> None:
    """Activate pipx settings."""
    os.environ.setdefault("PIPX_HOME", pipx_prefix())


def activate_ruby() -> None:
    """Activate Ruby gem environment."""
    gem_home = os.path.expanduser("~/.gem")
    os.environ.setdefault("GEM_HOME", gem_home)


def activate_docker() -> None:
    """Activate Docker environment."""
    os.environ.setdefault("DOCKER_BUILDKIT", "1")


def activate_ssh_key() -> None:
    """Start ssh-agent and add default key if not running."""
    auth_sock = os.environ.get("SSH_AUTH_SOCK", "")
    if not auth_sock:
        try:
            result = subprocess.run(
                ["ssh-agent", "-s"],
                capture_output=True,
                text=True,
                check=True,
            )
            for line in result.stdout.splitlines():
                if "=" in line and ";" in line:
                    kv = line.split(";")[0]
                    key, _, val = kv.partition("=")
                    os.environ[key] = val
        except FileNotFoundError:
            return
    key_file = os.path.expanduser("~/.ssh/id_ed25519")
    if not os.path.isfile(key_file):
        key_file = os.path.expanduser("~/.ssh/id_rsa")
    if os.path.isfile(key_file):
        with contextlib.suppress(FileNotFoundError):
            subprocess.run(
                ["ssh-add", key_file],
                capture_output=True,
                check=False,
            )


def activate_profile_files() -> None:
    """Source profile.d files (no-op in Python context)."""
    pass


def activate_ca_certificates() -> None:
    """Activate CA certificate paths."""
    ca_paths = [
        "/etc/ssl/certs/ca-certificates.crt",
        "/etc/pki/tls/certs/ca-bundle.crt",
        "/etc/ssl/ca-bundle.pem",
        "/etc/ssl/cert.pem",
    ]
    for ca in ca_paths:
        if os.path.isfile(ca):
            os.environ.setdefault("SSL_CERT_FILE", ca)
            os.environ.setdefault("REQUESTS_CA_BUNDLE", ca)
            os.environ.setdefault("CURL_CA_BUNDLE", ca)
            break


def activate_lesspipe() -> None:
    """Activate lesspipe for less preprocessing."""
    for cmd in ("lesspipe.sh", "lesspipe"):
        if shutil.which(cmd):
            os.environ["LESSOPEN"] = f"|{cmd} %s"
            break


def activate_macos_cli_colors() -> None:
    """Activate macOS CLI colors."""
    os.environ["CLICOLOR"] = "1"
    os.environ["LSCOLORS"] = "ExGxFxdxCxDxDxhbadExEx"


def set_umask() -> None:
    """Set default file creation mask."""
    os.umask(0o022)
