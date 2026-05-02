"""SSH helper functions.

Converted from Bash functions in ``lang/bash/functions/core/ssh-*.sh``.
"""

from __future__ import annotations

import os
import platform
import shutil
import subprocess


def ssh_generate_key(
    *key_names: str,
    prefix: str = "",
) -> None:
    """Generate SSH key(s)."""
    ssh_keygen = shutil.which("ssh-keygen")
    if ssh_keygen is None:
        msg = "ssh-keygen is not installed."
        raise RuntimeError(msg)
    ssh_keygen = os.path.realpath(ssh_keygen)
    if not prefix:
        prefix = os.path.join(os.path.expanduser("~"), ".ssh")
    if not key_names:
        key_names = ("id_rsa",)
    os.makedirs(prefix, mode=0o700, exist_ok=True)
    hostname = platform.node()
    user = os.environ.get("USER", "unknown")
    for key_name in key_names:
        key_file = os.path.join(prefix, key_name)
        if os.path.isfile(key_file):
            print(f"SSH key exists at '{key_file}'.")
            continue
        print(f"Generating SSH key at '{key_file}'.")
        ssh_args = [
            ssh_keygen,
            "-C", f"{user}@{hostname}",
            "-N", "",
            "-f", key_file,
            "-q",
        ]
        if key_name.endswith("-ed25519") or key_name.endswith("_ed25519"):
            ssh_args.extend(["-a", "100", "-o", "-t", "ed25519"])
        elif key_name.endswith("-rsa") or key_name.endswith("_rsa"):
            ssh_args.extend(["-b", "4096", "-t", "rsa"])
        else:
            msg = f"Unsupported key type: '{key_name}'."
            raise ValueError(msg)
        subprocess.run(ssh_args, check=True)
        print(f"Generated SSH key at '{key_file}'.")
