"""Install BCL Convert."""

import os
import subprocess

from koopa.archive import extract
from koopa.file_ops import init_dir


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install BCL Convert."""
    from koopa.aws import koopa_s3_bucket

    s3_base = f"s3://{koopa_s3_bucket('artifacts')}/installers"
    s3_url = f"{s3_base}/bcl-convert/{version}.tar.xz"
    local_file = f"{version}.tar.xz"
    subprocess.run(
        [
            "aws",
            "--profile=acidgenomics",
            "s3",
            "cp",
            s3_url,
            local_file,
        ],
        check=True,
    )
    libexec = os.path.join(prefix, "libexec")
    init_dir(libexec)
    extract(local_file, libexec)
