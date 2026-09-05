"""File system operations.

Converted from POSIX shell/Bash functions: mkdir, cp, mv, rm, ln, chmod, chown,
touch, write-string, append-string, delete-broken-symlinks, delete-empty-dirs,
find-broken-symlinks, find-empty-dirs, file-count, line-count, etc.
"""

import contextlib
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from koopa.exec import run


def mkdir(path: str, *, sudo: bool = False) -> None:
    """Create a directory recursively.

    Parameters
    ----------
    path : str
        Directory path to create.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    if sudo:
        run("mkdir", "-p", path, sudo=True, capture=True)
    else:
        Path(path).mkdir(parents=True, exist_ok=True)


def init_dir(path: str, *, sudo: bool = False) -> None:
    """Initialize (create) a directory if it does not exist.

    Parameters
    ----------
    path : str
        Directory path to initialize.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    if not os.path.isdir(path):
        mkdir(path, sudo=sudo)


def mktemp_dir(prefix: str = "koopa-") -> str:
    """Create a temporary directory.

    Parameters
    ----------
    prefix : str, optional
        Prefix to use for the generated directory name.

    Returns
    -------
    str
        Path to the created temporary directory.
    """
    return tempfile.mkdtemp(prefix=prefix)


def mktemp_file(prefix: str = "koopa-", suffix: str = "") -> str:
    """Create a temporary file and return its path.

    Parameters
    ----------
    prefix : str, optional
        Prefix to use for the generated file name.
    suffix : str, optional
        Suffix to use for the generated file name.

    Returns
    -------
    str
        Path to the created temporary file.
    """
    fd, path = tempfile.mkstemp(prefix=prefix, suffix=suffix)
    os.close(fd)
    return path


def cp(source: str, target: str, *, sudo: bool = False, recursive: bool = False) -> None:
    """Copy files or directories.

    Parameters
    ----------
    source : str
        Path to the file or directory to copy.
    target : str
        Destination path for the copy.
    sudo : bool, optional
        Run the operation with elevated privileges.
    recursive : bool, optional
        Copy directories recursively.
    """
    if sudo:
        args = ["cp"]
        if recursive:
            args.append("-r")
        args.extend([source, target])
        run(*args, sudo=True, capture=True)
    elif recursive or os.path.isdir(source):
        shutil.copytree(source, target, dirs_exist_ok=True)
    else:
        shutil.copy2(source, target)


def cp_to_dir(source: str, target_dir: str, *, sudo: bool = False) -> None:
    """Copy a file into a directory.

    Parameters
    ----------
    source : str
        Path to the file to copy.
    target_dir : str
        Destination directory, created if it does not exist.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    init_dir(target_dir, sudo=sudo)
    dest = os.path.join(target_dir, os.path.basename(source))
    cp(source, dest, sudo=sudo)


def mv(source: str, target: str, *, sudo: bool = False) -> None:
    """Move/rename a file or directory.

    Parameters
    ----------
    source : str
        Path to the file or directory to move.
    target : str
        Destination path.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    if sudo:
        run("mv", source, target, sudo=True, capture=True)
    else:
        shutil.move(source, target)


def mv_to_dir(source: str, target_dir: str, *, sudo: bool = False) -> None:
    """Move a file into a directory.

    Parameters
    ----------
    source : str
        Path to the file to move.
    target_dir : str
        Destination directory, created if it does not exist.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    init_dir(target_dir, sudo=sudo)
    dest = os.path.join(target_dir, os.path.basename(source))
    mv(source, dest, sudo=sudo)


def rm(path: str, *, sudo: bool = False) -> None:
    """Remove a file or directory.

    Parameters
    ----------
    path : str
        Path to the file or directory to remove.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    if sudo:
        run("rm", "-rf", path, sudo=True, capture=True)
    elif os.path.isdir(path) and not os.path.islink(path):
        shutil.rmtree(path)
    elif os.path.exists(path) or os.path.islink(path):
        os.remove(path)


def ln(source: str, target: str, *, sudo: bool = False) -> None:
    """Create a symbolic link.

    Parameters
    ----------
    source : str
        Path that the symbolic link points to.
    target : str
        Path of the symbolic link to create.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    if sudo:
        run("ln", "-sfn", source, target, sudo=True, capture=True)
    else:
        target_path = Path(target)
        if target_path.is_symlink():
            target_path.unlink()
        elif target_path.is_dir():
            shutil.rmtree(target_path)
        elif target_path.exists():
            target_path.unlink()
        target_path.symlink_to(source)


def ln_to_dir(source: str, target_dir: str, *, sudo: bool = False) -> None:
    """Create a symbolic link inside a directory.

    Parameters
    ----------
    source : str
        Path that the symbolic link points to.
    target_dir : str
        Destination directory, created if it does not exist.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    init_dir(target_dir, sudo=sudo)
    dest = os.path.join(target_dir, os.path.basename(source))
    ln(source, dest, sudo=sudo)


def chmod(path: str, mode: str | int, *, sudo: bool = False, recursive: bool = False) -> None:
    """Change file permissions.

    Parameters
    ----------
    path : str
        Path to the file or directory.
    mode : str | int
        Permission mode, as an octal string (e.g. ``"755"``) or an int.
    sudo : bool, optional
        Run the operation with elevated privileges.
    recursive : bool, optional
        Apply the permission change recursively.
    """
    if sudo or recursive:
        args = ["chmod"]
        if recursive:
            args.append("-R")
        args.extend([str(mode), path])
        run(*args, sudo=sudo, capture=True)
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
    """Change file ownership.

    Parameters
    ----------
    path : str
        Path to the file or directory.
    user : str | None, optional
        User name or ID to set as owner.
    group : str | None, optional
        Group name or ID to set as owner.
    sudo : bool, optional
        Run the operation with elevated privileges.
    recursive : bool, optional
        Apply the ownership change recursively.
    """
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
    run(*args, sudo=sudo, capture=True)


def touch(path: str, *, sudo: bool = False) -> None:
    """Touch a file (create if not exists, update timestamp).

    Parameters
    ----------
    path : str
        Path to the file to touch.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
    if sudo:
        run("touch", path, sudo=True, capture=True)
    else:
        Path(path).touch()


def write_string(string: str, path: str, *, sudo: bool = False) -> None:
    """Write a string to a file.

    Parameters
    ----------
    string : str
        Text content to write.
    path : str
        Path to the file to write.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
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
    """Append a string to a file.

    Parameters
    ----------
    string : str
        Text content to append.
    path : str
        Path to the file to append to.
    sudo : bool, optional
        Run the operation with elevated privileges.
    """
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
    """Read a file and return lines.

    Parameters
    ----------
    path : str
        Path to the file to read.

    Returns
    -------
    list[str]
        Lines of the file, with line endings stripped.
    """
    return Path(path).read_text().splitlines()


def basename(path: str) -> str:
    """Return the base name of a path.

    Parameters
    ----------
    path : str
        Path to extract the base name from.

    Returns
    -------
    str
        Final component of the path.
    """
    return os.path.basename(path)


def basename_sans_ext(path: str) -> str:
    """Return basename without extension.

    Parameters
    ----------
    path : str
        Path to extract the base name from.

    Returns
    -------
    str
        Final component of the path, with its extension removed.
    """
    return Path(path).stem


def dirname(path: str) -> str:
    """Return the directory name of a path.

    Parameters
    ----------
    path : str
        Path to extract the directory name from.

    Returns
    -------
    str
        Directory portion of the path.
    """
    return os.path.dirname(path)


def parent_dir(path: str, n: int = 1) -> str:
    """Return the nth parent directory.

    Parameters
    ----------
    path : str
        Path to start from.
    n : int, optional
        Number of parent levels to walk up.

    Returns
    -------
    str
        Path of the nth parent directory.
    """
    p = Path(path)
    for _ in range(n):
        p = p.parent
    return str(p)


def realpath(path: str) -> str:
    """Return the real (resolved) path.

    Parameters
    ----------
    path : str
        Path to resolve.

    Returns
    -------
    str
        Absolute path with symbolic links resolved.
    """
    return str(Path(path).resolve())


def file_ext(path: str) -> str:
    """Return the file extension.

    Parameters
    ----------
    path : str
        Path to extract the extension from.

    Returns
    -------
    str
        File extension, including the leading dot.
    """
    return Path(path).suffix


def strip_trailing_slash(path: str) -> str:
    """Strip trailing slash from a path.

    Parameters
    ----------
    path : str
        Path to strip.

    Returns
    -------
    str
        Path with any trailing slashes removed.
    """
    return path.rstrip("/")


def which(name: str) -> str:
    """Locate a command in PATH.

    Parameters
    ----------
    name : str
        Command name to locate.

    Returns
    -------
    str
        Absolute path to the command.
    """
    result = shutil.which(name)
    if result is None:
        msg = f"Command not found: {name}"
        raise FileNotFoundError(msg)
    return result


def delete_broken_symlinks(dir_path: str) -> None:
    """Delete broken symbolic links in a directory.

    Parameters
    ----------
    dir_path : str
        Directory to search recursively.
    """
    for root, _dirs, files in os.walk(dir_path):
        for f in files:
            full = os.path.join(root, f)
            if os.path.islink(full) and not os.path.exists(full):
                os.remove(full)


def delete_empty_dirs(dir_path: str) -> None:
    """Delete empty directories recursively.

    Parameters
    ----------
    dir_path : str
        Directory to search recursively.
    """
    for root, dirs, _files in os.walk(dir_path, topdown=False):
        for d in dirs:
            full = os.path.join(root, d)
            with contextlib.suppress(OSError):
                os.rmdir(full)


def find_broken_symlinks(dir_path: str) -> list[str]:
    """Find broken symbolic links in a directory.

    Parameters
    ----------
    dir_path : str
        Directory to search recursively.

    Returns
    -------
    list[str]
        Paths of broken symbolic links found.
    """
    broken = []
    for root, _dirs, files in os.walk(dir_path):
        for f in files:
            full = os.path.join(root, f)
            if os.path.islink(full) and not os.path.exists(full):
                broken.append(full)
    return broken


def find_empty_dirs(dir_path: str) -> list[str]:
    """Find empty directories.

    Parameters
    ----------
    dir_path : str
        Directory to search recursively.

    Returns
    -------
    list[str]
        Paths of empty directories found.
    """
    empty = []
    for root, dirs, _files in os.walk(dir_path, topdown=False):
        for d in dirs:
            full = os.path.join(root, d)
            if not os.listdir(full):
                empty.append(full)
    return empty


def file_count(dir_path: str, *, pattern: str = "*", recursive: bool = True) -> int:
    """Count files in a directory.

    Parameters
    ----------
    dir_path : str
        Directory to count files in.
    pattern : str, optional
        Glob pattern used to match file names.
    recursive : bool, optional
        Search subdirectories recursively.

    Returns
    -------
    int
        Number of files matching the pattern.
    """
    p = Path(dir_path)
    if recursive:
        return sum(1 for f in p.rglob(pattern) if f.is_file())
    return sum(1 for f in p.glob(pattern) if f.is_file())


def line_count(path: str) -> int:
    """Count lines in a file.

    Parameters
    ----------
    path : str
        Path to the file to count lines in.

    Returns
    -------
    int
        Number of lines in the file.
    """
    with open(path) as f:
        return sum(1 for _ in f)


def delete_named_subdirs(dir_path: str, name: str) -> list[str]:
    """Find and delete subdirectories with a given name.

    Parameters
    ----------
    dir_path : str
        Directory to search recursively.
    name : str
        Subdirectory name to match and delete.

    Returns
    -------
    list[str]
        Paths of the deleted subdirectories.
    """
    deleted = []
    for root, dirs, _ in os.walk(dir_path, topdown=False):
        if name in dirs:
            full = os.path.join(root, name)
            shutil.rmtree(full)
            deleted.append(full)
    return deleted
