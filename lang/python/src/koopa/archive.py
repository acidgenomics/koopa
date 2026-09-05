"""Archive and compression functions.

Converted from Bash/POSIX shell functions: extract, decompress,
tar-multiple-dirs, compress, etc.
"""

import bz2
import gzip
import os
import shutil
import subprocess
import tarfile
import zipfile
from pathlib import Path


def is_valid_archive(path: str) -> bool:
    """Check if a file looks like a valid compressed archive via magic bytes.

    Parameters
    ----------
    path : str
        Path to the file to inspect.

    Returns
    -------
    bool
        True if the file's magic bytes match a known archive format.
    """
    try:
        with open(path, "rb") as f:
            header = f.read(6)
    except OSError:
        return False
    if len(header) < 4:
        return False
    return (
        header[:2] == b"\x1f\x8b"
        or header[:3] == b"BZh"
        or header[:6] == b"\xfd7zXZ\x00"
        or header[:4] == b"\x28\xb5\x2f\xfd"
        or header[:4] == b"LZIP"
    )


def extract(path: str, output_dir: str | None = None) -> None:
    """Extract an archive (tar, zip, 7z).

    Matches bash ``koopa_extract`` behaviour: extracts to a temporary
    directory, then flattens single top-level directories so the caller
    always gets normalized output regardless of archive structure.

    Supports: .tar, .tar.gz, .tgz, .tar.bz2, .tbz2, .tar.xz, .txz,
    .tar.zst, .zip, .7z

    Parameters
    ----------
    path : str
        Path to the archive file to extract.
    output_dir : str | None, optional
        Directory to extract into. Defaults to a directory named after
        the archive, alongside the archive file.
    """
    import glob as glob_mod
    import tempfile

    path = os.path.realpath(path)
    if output_dir is None:
        bn = os.path.basename(path)
        for ext in (
            ".tar.gz",
            ".tar.bz2",
            ".tar.xz",
            ".tar.zst",
            ".tar.zstd",
            ".tar.lz",
            ".tgz",
            ".tbz2",
            ".txz",
            ".tar",
            ".zip",
            ".7z",
        ):
            if bn.lower().endswith(ext):
                bn = bn[: -len(ext)]
                break
        output_dir = os.path.join(os.path.dirname(path), bn)
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    tmpdir = tempfile.mkdtemp(
        dir=os.path.dirname(path) or ".",
        prefix=".koopa-extract-",
    )
    try:
        _extract_to(path, tmpdir)
        entries = [e for e in os.listdir(tmpdir) if not e.startswith(".")]
        if len(entries) == 1 and os.path.isdir(os.path.join(tmpdir, entries[0])):
            src_dir = os.path.join(tmpdir, entries[0])
            for item in glob_mod.glob(os.path.join(src_dir, "*")) + glob_mod.glob(
                os.path.join(src_dir, ".*")
            ):
                bn_item = os.path.basename(item)
                if bn_item in (".", ".."):
                    continue
                dst = os.path.join(output_dir, bn_item)
                if os.path.exists(dst) or os.path.islink(dst):
                    if os.path.isdir(dst) and not os.path.islink(dst):
                        shutil.rmtree(dst)
                    else:
                        os.unlink(dst)
                shutil.move(item, dst)
        else:
            for entry in entries:
                src = os.path.join(tmpdir, entry)
                dst = os.path.join(output_dir, entry)
                if os.path.exists(dst) or os.path.islink(dst):
                    if os.path.isdir(dst) and not os.path.islink(dst):
                        shutil.rmtree(dst)
                    else:
                        os.unlink(dst)
                shutil.move(src, dst)
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def _extract_to(path: str, target: str) -> None:
    """Extract archive contents into target directory.

    Parameters
    ----------
    path : str
        Path to the archive file to extract.
    target : str
        Directory to extract the archive contents into.
    """
    if not is_valid_archive(path) and not zipfile.is_zipfile(path):
        name_lower = os.path.basename(path).lower()
        if not name_lower.endswith(".7z"):
            msg = f"Not a valid archive (corrupt or not an archive): {path}"
            raise ValueError(msg)
    name = os.path.basename(path).lower()
    if name.endswith((".tar.xz", ".txz", ".tar.zst", ".tar.zstd", ".tar.lz")):
        subprocess.run(
            ["tar", "-xf", path, "-C", target],
            check=True,
        )
    elif name.endswith(
        (
            ".tar.gz",
            ".tgz",
            ".tar.bz2",
            ".tbz2",
            ".tar",
        )
    ) or tarfile.is_tarfile(path):
        with tarfile.open(path) as tf:
            tf.extractall(path=target)
    elif zipfile.is_zipfile(path):
        with zipfile.ZipFile(path) as zf:
            zf.extractall(path=target)
    elif name.endswith(".7z"):
        subprocess.run(["7z", "x", path, f"-o{target}"], check=True)
    else:
        msg = f"Unsupported archive format: {path}"
        raise ValueError(msg)


def decompress(path: str, output: str | None = None) -> str:
    """Decompress a single compressed file.

    Supports: .gz, .bz2, .xz, .lzma, .zst, .lz4, .lz, .br

    Parameters
    ----------
    path : str
        Path to the compressed file.
    output : str | None, optional
        Path to write the decompressed file to. Defaults to ``path`` with
        its compression extension removed, or ``path`` plus
        ``".decompressed"`` if the extension is unrecognized.

    Returns
    -------
    str
        Path to the decompressed output file.
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
        with open(output, "wb") as f_out:
            subprocess.run(["xz", "-dc", path], stdout=f_out, check=True)
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
    """Create tar.gz archives for multiple directories.

    Parameters
    ----------
    dirs : list[str]
        Paths to the directories to archive, one archive per directory.
    output_dir : str | None, optional
        Directory to write the resulting archives into. Defaults to the
        current directory.

    Returns
    -------
    list[str]
        Paths to the created tar.gz archives, in the same order as ``dirs``.
    """
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


def _copy_tar_members(tf_in: tarfile.TarFile, tf_out: tarfile.TarFile) -> None:
    for member in tf_in.getmembers():
        fileobj = tf_in.extractfile(member) if member.isfile() else None
        tf_out.addfile(member, fileobj)


def repackage_tar(path: str, output: str, *, method: str = "xz") -> str:
    """Transcode a tar archive to a different compression method.

    Preserves member names, order, and metadata (permissions, symlinks) exactly:
    only the outer compression changes. Used to restage vendor-downloaded tarballs
    (typically .tar.gz) as .tar.xz without disturbing the internal layout that
    installers rely on after ``extract()``.

    Parameters
    ----------
    path : str
        Path to the source tar archive to read.
    output : str
        Path to write the recompressed tar archive to.
    method : str, optional
        Compression method for the output archive: ``"gzip"``, ``"bzip2"``,
        or ``"xz"``.

    Returns
    -------
    str
        Path to the recompressed output archive.
    """
    with tarfile.open(path, "r:*") as tf_in:
        if method == "gzip":
            with tarfile.open(output, "w:gz") as tf_out:
                _copy_tar_members(tf_in, tf_out)
        elif method == "bzip2":
            with tarfile.open(output, "w:bz2") as tf_out:
                _copy_tar_members(tf_in, tf_out)
        elif method == "xz":
            with tarfile.open(output, "w:xz") as tf_out:
                _copy_tar_members(tf_in, tf_out)
        else:
            msg = f"Unsupported tar compression method: {method}"
            raise ValueError(msg)
    return output


def compress(
    path: str,
    output: str | None = None,
    *,
    method: str = "gzip",
) -> str:
    """Compress a file or directory.

    Parameters
    ----------
    path : str
        Path to the file or directory to compress. A directory is
        archived as a tar.gz regardless of ``method``.
    output : str | None, optional
        Path to write the compressed output to. Defaults to ``path`` with
        a compression extension appended.
    method : str, optional
        Compression method for a file input: ``"gzip"``, ``"bzip2"``,
        ``"xz"``, or ``"zstd"``.

    Returns
    -------
    str
        Path to the compressed output file.
    """
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
        with open(output, "wb") as f_out:
            subprocess.run(["xz", "-zc", path], stdout=f_out, check=True)
    elif method == "zstd":
        subprocess.run(["zstd", path, "-o", output], check=True)
    else:
        msg = f"Unsupported compression method: {method}"
        raise ValueError(msg)
    return output
