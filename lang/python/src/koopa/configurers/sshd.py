"""Configure sshd."""

from __future__ import annotations

import os

from koopa.file_ops import append_string, chmod, write_string


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure system sshd.

    Creates a 'koopa.conf' file, which contains passthrough support of
    'KOOPA_COLOR_MODE' environment variable.
    """
    sshd_file = "/etc/ssh/sshd_config"
    koopa_file = "/etc/ssh/sshd_config.d/koopa.conf"
    if not os.path.isfile(sshd_file):
        msg = f"sshd_config not found: {sshd_file}"
        raise FileNotFoundError(msg)
    # Check if sshd_config already includes sshd_config.d.
    include_line = "Include /etc/ssh/sshd_config.d/*.conf"
    with open(sshd_file) as f:
        content = f.read()
    if include_line not in content:
        append_string(include_line + "\n", sshd_file, sudo=True)
    chmod(sshd_file, "0644", sudo=True)
    # Write koopa.conf.
    koopa_conf_dir = os.path.dirname(koopa_file)
    if not os.path.isdir(koopa_conf_dir):
        from koopa.file_ops import mkdir

        mkdir(koopa_conf_dir, sudo=True)
    write_string("AcceptEnv KOOPA_COLOR_MODE\n", koopa_file, sudo=True)
    chmod(koopa_file, "0644", sudo=True)
