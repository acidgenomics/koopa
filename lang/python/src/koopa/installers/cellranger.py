"""Install Cell Ranger."""

import os
import subprocess

from koopa.archive import extract
from koopa.file_ops import init_dir, ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Cell Ranger.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    from koopa.app import installer_artifact_key
    from koopa.aws import koopa_s3_bucket, s3_object_exists
    from koopa.io import import_app_json

    bucket = koopa_s3_bucket("artifacts")
    key = installer_artifact_key(name, version)
    if key is None:
        msg = f"'{name}' is missing 'installer_artifact' in app.json."
        raise RuntimeError(msg)
    if not s3_object_exists(bucket, key):
        entry = import_app_json().get(name, {})
        urls = entry.get("url", []) if isinstance(entry, dict) else []
        download_url = urls[0] if urls else "the vendor downloads page"
        msg = (
            f"'{name}' {version} is not staged in the private artifacts bucket.\n"
            f"Download the Linux tarball from {download_url}, then run:\n"
            f"    koopa develop push-installer {name} <file>"
        )
        raise RuntimeError(msg)
    local_file = os.path.basename(key)
    subprocess.run(
        [
            "aws",
            "--profile=acidgenomics",
            "s3",
            "cp",
            f"s3://{bucket}/{key}",
            local_file,
        ],
        check=True,
    )
    libexec = os.path.join(prefix, "libexec")
    init_dir(libexec)
    extract(local_file, libexec)
    bin_dir = os.path.join(libexec, "bin")
    if not os.path.isdir(bin_dir):
        nested_archives = [
            os.path.join(libexec, entry)
            for entry in os.listdir(libexec)
            if entry.lower().endswith(".tar") and os.path.isfile(os.path.join(libexec, entry))
        ]
        if len(nested_archives) == 1:
            extract(nested_archives[0], libexec)
    if not os.path.isdir(bin_dir):
        msg = (
            f"'{name}' {version} archive layout has no top-level 'bin/' directory"
            f" after extraction (expected at '{libexec}/bin').\n"
            "The vendor tarball layout may have changed; update this installer's"
            " link step to match."
        )
        raise RuntimeError(msg)
    ln("libexec/bin", os.path.join(prefix, "bin"))
