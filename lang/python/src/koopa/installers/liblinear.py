"""Install liblinear."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate, shared_ext
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install liblinear."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    ext = shared_ext()
    url = f"https://github.com/cjlin1/liblinear/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    with open("Makefile") as fh:
        text = fh.read()
    text = text.replace(".so", f".{ext}")
    with open("Makefile", "w") as fh:
        fh.write(text)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}", "lib"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, f"--jobs={jobs}", "predict", "train"],
        env=subprocess_env,
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    lib_dir = os.path.join(prefix, "lib")
    inc_dir = os.path.join(prefix, "include")
    for d in (bin_dir, lib_dir, inc_dir):
        os.makedirs(d, exist_ok=True)
    for f in ("predict", "train"):
        dest = os.path.join(bin_dir, f)
        with open(f, "rb") as src_fh, open(dest, "wb") as dst_fh:
            dst_fh.write(src_fh.read())
        os.chmod(dest, 0o755)
    for f in ("linear.h", "tron.h"):
        if os.path.exists(f):
            with open(f, "rb") as src_fh:
                with open(os.path.join(inc_dir, f), "wb") as dst_fh:
                    dst_fh.write(src_fh.read())
    lib_name = f"liblinear.{ext}"
    for f in os.listdir("."):
        if f.startswith("liblinear.") and f.endswith(f".{ext}"):
            with open(f, "rb") as src_fh:
                with open(os.path.join(lib_dir, f), "wb") as dst_fh:
                    dst_fh.write(src_fh.read())
    if sys.platform == "darwin":
        ln(f"liblinear.{ext}", os.path.join(lib_dir, lib_name))
    else:
        real_lib = f"liblinear.{ext}.5"
        if os.path.exists(os.path.join(lib_dir, real_lib)):
            ln(real_lib, os.path.join(lib_dir, lib_name))
