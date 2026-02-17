"""Archive and compression functions.

Converted from Bash/POSIX shell functions: extract, decompress,
tar-multiple-dirs, compress, etc.
"""

from __future__ import annotations

import bz2
import gzip
import lzma
import os
import shutil
import subprocess
import tarfile
import zipfile
from pathlib import Path


def extract(path: str, output_dir: str | None = None) -> None:
    """Extract an archive (tar, zip, 7z).

    Supports: .tar, .tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz, .txz,
    .tar.zst, .zip, .7z
    """
    if output_dir is None:
        output_dir = os.path.dirname(path) or "."
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    name = os.path.basename(path).lower()
    if name.endswith((".tar.zst", ".tar.zstd")):
        subprocess.run(
            ["tar", "--zstd", "-xf", path, "-C", output_dir],
            check=True,
        )
    elif tarfile.is_tarfile(path):
        with tarfile.open(path) as tf:
            tf.extractall(path=output_dir)
    elif zipfile.is_zipfile(path):
        with zipfile.ZipFile(path) as zf:
            zf.extractall(path=output_dir)
    elif name.endswith(".7z"):
        subprocess.run(["7z", "x", path, f"-o{output_dir}"], check=True)
    else:
        msg = f"Unsupported archive format: {path}"
        raise ValueError(msg)


def decompress(path: str, output: str | None = None) -> str:
    """Decompress a single compressed file.

    Supports: .gz, .bz2, .xz, .lzma, .zst, .lz4, .lz, .br
    """
    name = path.lower()
    if output is None:
        for ext in (".gz", ".bz2", ".xz", ".lzma", ".zst", ".lz4", ".lz", ".br"):
            if name.endswith(ext):
                output = path[: -len(ext)]
                break
        else:
            output = path + ".decompressed"
    if name.endswith(".gz"):
        with gzip.open(path, "rb") as f_in, open(output, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    elif name.endswith(".bz2"):
        with bz2.open(path, "rb") as f_in, open(output, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    elif name.endswith((".xz", ".lzma")):
        with lzma.open(path, "rb") as f_in, open(output, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    elif name.endswith((".zst", ".zstd")):
        subprocess.run(["zstd", "-d", path, "-o", output], check=True)
    elif name.endswith(".lz4"):
        subprocess.run(["lz4", "-d", path, output], check=True)
    elif name.endswith(".lz"):
        subprocess.run(["lzip", "-d", "-k", path, "-o", output], check=True)
    elif name.endswith(".br"):
        subprocess.run(["brotli", "-d", path, "-o", output], check=True)
    else:
        msg = f"Unsupported compression format: {path}"
        raise ValueError(msg)
    return output


def tar_multiple_dirs(dirs: list[str], output_dir: str | None = None) -> list[str]:
    """Create tar.gz archives for multiple directories."""
    if output_dir is None:
        output_dir = "."
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    archives = []
    for d in dirs:
        name = os.path.basename(d.rstrip("/"))
        out = os.path.join(output_dir, f"{name}.tar.gz")
        with tarfile.open(out, "w:gz") as tf:
            tf.add(d, arcname=name)
        archives.append(out)
    return archives


def compress(
    path: str,
    output: str | None = None,
    *,
    method: str = "gzip",
) -> str:
    """Compress a file or directory."""
    if os.path.isdir(path):
        if output is None:
            output = path.rstrip("/") + ".tar.gz"
        name = os.path.basename(path.rstrip("/"))
        with tarfile.open(output, "w:gz") as tf:
            tf.add(path, arcname=name)
        return output
    if output is None:
        ext_map = {"gzip": ".gz", "bzip2": ".bz2", "xz": ".xz", "zstd": ".zst"}
        output = path + ext_map.get(method, ".gz")
    if method == "gzip":
        with open(path, "rb") as f_in, gzip.open(output, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    elif method == "bzip2":
        with open(path, "rb") as f_in, bz2.open(output, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    elif method == "xz":
        with open(path, "rb") as f_in, lzma.open(output, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    elif method == "zstd":
        subprocess.run(["zstd", path, "-o", output], check=True)
    else:
        msg = f"Unsupported compression method: {method}"
        raise ValueError(msg)
    return output
