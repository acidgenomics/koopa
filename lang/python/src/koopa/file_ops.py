"""File system operations.

Converted from POSIX shell/Bash functions: mkdir, cp, mv, rm, ln, chmod, chown,
touch, write-string, append-string, delete-broken-symlinks, delete-empty-dirs,
find-broken-symlinks, find-empty-dirs, file-count, line-count, etc.
"""

from __future__ import annotations

import contextlib
import os
import shutil
import subprocess
import tempfile
from pathlib import Path


def _run(args: list[str], *, sudo: bool = False) -> subprocess.CompletedProcess:
    """Run a command, optionally with sudo."""
    if sudo:
        args = ["sudo"] + args
    return subprocess.run(args, check=True, capture_output=True, text=True)


def mkdir(path: str, *, sudo: bool = False) -> None:
    """Create a directory recursively."""
    if sudo:
        _run(["mkdir", "-p", path], sudo=True)
    else:
        Path(path).mkdir(parents=True, exist_ok=True)


def init_dir(path: str, *, sudo: bool = False) -> None:
    """Initialize (create) a directory if it does not exist."""
    if not os.path.isdir(path):
        mkdir(path, sudo=sudo)


def mktemp_dir(prefix: str = "koopa-") -> str:
    """Create a temporary directory."""
    return tempfile.mkdtemp(prefix=prefix)


def mktemp_file(prefix: str = "koopa-", suffix: str = "") -> str:
    """Create a temporary file and return its path."""
    fd, path = tempfile.mkstemp(prefix=prefix, suffix=suffix)
    os.close(fd)
    return path


def cp(source: str, target: str, *, sudo: bool = False, recursive: bool = False) -> None:
    """Copy files or directories."""
    if sudo:
        args = ["cp"]
        if recursive:
            args.append("-r")
        args.extend([source, target])
        _run(args, sudo=True)
    elif recursive or os.path.isdir(source):
        shutil.copytree(source, target, dirs_exist_ok=True)
    else:
        shutil.copy2(source, target)


def cp_to_dir(source: str, target_dir: str, *, sudo: bool = False) -> None:
    """Copy a file into a directory."""
    init_dir(target_dir, sudo=sudo)
    dest = os.path.join(target_dir, os.path.basename(source))
    cp(source, dest, sudo=sudo)


def mv(source: str, target: str, *, sudo: bool = False) -> None:
    """Move/rename a file or directory."""
    if sudo:
        _run(["mv", source, target], sudo=True)
    else:
        shutil.move(source, target)


def mv_to_dir(source: str, target_dir: str, *, sudo: bool = False) -> None:
    """Move a file into a directory."""
    init_dir(target_dir, sudo=sudo)
    dest = os.path.join(target_dir, os.path.basename(source))
    mv(source, dest, sudo=sudo)


def rm(path: str, *, sudo: bool = False) -> None:
    """Remove a file or directory."""
    if sudo:
        _run(["rm", "-rf", path], sudo=True)
    elif os.path.isdir(path) and not os.path.islink(path):
        shutil.rmtree(path)
    elif os.path.exists(path) or os.path.islink(path):
        os.remove(path)


def ln(source: str, target: str, *, sudo: bool = False) -> None:
    """Create a symbolic link."""
    if sudo:
        _run(["ln", "-sfn", source, target], sudo=True)
    else:
        target_path = Path(target)
        if target_path.is_symlink() or target_path.exists():
            target_path.unlink()
        target_path.symlink_to(source)


def ln_to_dir(source: str, target_dir: str, *, sudo: bool = False) -> None:
    """Create a symbolic link inside a directory."""
    init_dir(target_dir, sudo=sudo)
    dest = os.path.join(target_dir, os.path.basename(source))
    ln(source, dest, sudo=sudo)


def chmod(path: str, mode: str | int, *, sudo: bool = False, recursive: bool = False) -> None:
    """Change file permissions."""
    if sudo or recursive:
        args = ["chmod"]
        if recursive:
            args.append("-R")
        args.extend([str(mode), path])
        _run(args, sudo=sudo)
    else:
        if isinstance(mode, str):
            mode = int(mode, 8)
        os.chmod(path, mode)


def chown(
    path: str,
    user: str | None = None,
    group: str | None = None,
    *,
    sudo: bool = False,
    recursive: bool = False,
) -> None:
    """Change file ownership."""
    owner = ""
    if user:
        owner = user
    if group:
        owner += f":{group}"
    if not owner:
        return
    args = ["chown"]
    if recursive:
        args.append("-R")
    args.extend([owner, path])
    _run(args, sudo=sudo)


def touch(path: str, *, sudo: bool = False) -> None:
    """Touch a file (create if not exists, update timestamp)."""
    if sudo:
        _run(["touch", path], sudo=True)
    else:
        Path(path).touch()


def write_string(string: str, path: str, *, sudo: bool = False) -> None:
    """Write a string to a file."""
    if sudo:
        subprocess.run(
            ["sudo", "tee", path],
            input=string,
            capture_output=True,
            text=True,
            check=True,
        )
    else:
        Path(path).write_text(string)


def append_string(string: str, path: str, *, sudo: bool = False) -> None:
    """Append a string to a file."""
    if sudo:
        subprocess.run(
            ["sudo", "tee", "-a", path],
            input=string,
            capture_output=True,
            text=True,
            check=True,
        )
    else:
        with open(path, "a") as f:
            f.write(string)


def read_lines(path: str) -> list[str]:
    """Read a file and return lines."""
    return Path(path).read_text().splitlines()


def basename(path: str) -> str:
    """Return the base name of a path."""
    return os.path.basename(path)


def basename_sans_ext(path: str) -> str:
    """Return basename without extension."""
    return Path(path).stem


def dirname(path: str) -> str:
    """Return the directory name of a path."""
    return os.path.dirname(path)


def parent_dir(path: str, n: int = 1) -> str:
    """Return the nth parent directory."""
    p = Path(path)
    for _ in range(n):
        p = p.parent
    return str(p)


def realpath(path: str) -> str:
    """Return the real (resolved) path."""
    return str(Path(path).resolve())


def file_ext(path: str) -> str:
    """Return the file extension."""
    return Path(path).suffix


def strip_trailing_slash(path: str) -> str:
    """Strip trailing slash from a path."""
    return path.rstrip("/")


def which(name: str) -> str:
    """Locate a command in PATH."""
    result = shutil.which(name)
    if result is None:
        msg = f"Command not found: {name}"
        raise FileNotFoundError(msg)
    return result


def delete_broken_symlinks(dir_path: str) -> None:
    """Delete broken symbolic links in a directory."""
    for root, _dirs, files in os.walk(dir_path):
        for f in files:
            full = os.path.join(root, f)
            if os.path.islink(full) and not os.path.exists(full):
                os.remove(full)


def delete_empty_dirs(dir_path: str) -> None:
    """Delete empty directories recursively."""
    for root, dirs, _files in os.walk(dir_path, topdown=False):
        for d in dirs:
            full = os.path.join(root, d)
            with contextlib.suppress(OSError):
                os.rmdir(full)


def find_broken_symlinks(dir_path: str) -> list[str]:
    """Find broken symbolic links in a directory."""
    broken = []
    for root, _dirs, files in os.walk(dir_path):
        for f in files:
            full = os.path.join(root, f)
            if os.path.islink(full) and not os.path.exists(full):
                broken.append(full)
    return broken


def find_empty_dirs(dir_path: str) -> list[str]:
    """Find empty directories."""
    empty = []
    for root, dirs, _files in os.walk(dir_path, topdown=False):
        for d in dirs:
            full = os.path.join(root, d)
            if not os.listdir(full):
                empty.append(full)
    return empty


def file_count(dir_path: str, *, pattern: str = "*", recursive: bool = True) -> int:
    """Count files in a directory."""
    p = Path(dir_path)
    if recursive:
        return sum(1 for f in p.rglob(pattern) if f.is_file())
    return sum(1 for f in p.glob(pattern) if f.is_file())


def line_count(path: str) -> int:
    """Count lines in a file."""
    with open(path) as f:
        return sum(1 for _ in f)


def find_large_files(dir_path: str, min_size_mb: float = 100) -> list[tuple[str, float]]:
    """Find files larger than a threshold."""
    large = []
    min_bytes = min_size_mb * 1024 * 1024
    for root, _dirs, files in os.walk(dir_path):
        for f in files:
            full = os.path.join(root, f)
            try:
                size = os.path.getsize(full)
                if size >= min_bytes:
                    large.append((full, size / (1024 * 1024)))
            except OSError:
                pass
    large.sort(key=lambda x: x[1], reverse=True)
    return large


def find_large_dirs(dir_path: str, min_size_mb: float = 100) -> list[tuple[str, float]]:
    """Find directories larger than a threshold."""
    dir_sizes: dict[str, float] = {}
    for root, _dirs, files in os.walk(dir_path):
        total = 0.0
        for f in files:
            full = os.path.join(root, f)
            with contextlib.suppress(OSError):
                total += os.path.getsize(full)
        dir_sizes[root] = total / (1024 * 1024)
    large = [(d, s) for d, s in dir_sizes.items() if s >= min_size_mb]
    large.sort(key=lambda x: x[1], reverse=True)
    return large
