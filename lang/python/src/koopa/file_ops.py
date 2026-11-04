"""File system operations.

Converted from POSIX shell/Bash functions: mkdir, cp, mv, rm, ln, chmod, chown,
touch, write-string, append-string, delete-broken-symlinks, delete-empty-dirs,
find-broken-symlinks, find-empty-dirs, file-count, line-count, etc.
"""

import contextlib
import os
import re
import shutil
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path

from koopa.exec import run

# macOS default name, for example "Screenshot 2026-10-01 at 7.17.11 AM.png".
# The optional " (N)" suffix is macOS's duplicate marker.
_MACOS_AM_PM = re.compile(
    r"^(?P<prefix>Screenshot|Screen Recording) (?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})"
    r" at (?P<hour>\d{1,2})\.(?P<minute>\d{2})\.(?P<second>\d{2})[ \u202f]"
    r"(?P<meridiem>am|pm)(?P<dup> \(\d+\))?(?P<ext>\.(?:png|mov))$",
    re.IGNORECASE,
)
# Earlier kebab-case name, for example "screenshot-2026-10-01-at-7-17-11-am.png".
# The optional "-N" suffixes are duplicate markers from the old rename.
_LEGACY_AM_PM = re.compile(
    r"^(?P<prefix>screenshot|screen-recording)-(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})"
    r"-at-(?P<hour>\d{1,2})-(?P<minute>\d{2})-(?P<second>\d{2})-(?P<meridiem>am|pm)"
    r"(?P<dup>(?:-\d+)+)?(?P<ext>\.(?:png|mov))$",
    re.IGNORECASE,
)
# Name from 2024, for example "screenshot-2024-06-10-102152.png", already on a 24-hour clock.
_HOUR24_NAME = re.compile(
    r"^(?P<prefix>screenshot)-(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})"
    r"-(?P<hour>\d{2})(?P<minute>\d{2})(?P<second>\d{2})(?P<ext>\.png)$"
)
# Final name, for example "screenshot-2026-10-01-07-17-11.png" or "...-07-17-11-1.png".
_FINAL_NAME = re.compile(
    r"^(?P<prefix>screenshot|screen-recording)-(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})"
    r"-(?P<hour>\d{2})-(?P<minute>\d{2})-(?P<second>\d{2})(?P<dup>-\d+)?(?P<ext>\.(?:png|mov))$"
)
_SCREENSHOT_SUFFIXES = frozenset({".png", ".mov"})


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


def _screenshot_destination(name: str) -> tuple[str, str] | None:
    """Return the dated folder and the 24-hour name for a screenshot file name.

    Parameters
    ----------
    name : str
        File name, for example ``"Screenshot 2026-10-01 at 7.17.11 PM.png"``.

    Returns
    -------
    tuple[str, str] | None
        Folder as ``YYYY/MM/DD`` and new name as ``screenshot-YYYY-MM-DD-HH-MM-SS.png``,
        or ``None`` when the name matches no known form or is not a valid time.
    """
    am_pm = _MACOS_AM_PM.fullmatch(name) or _LEGACY_AM_PM.fullmatch(name)
    if am_pm is not None:
        hour12 = int(am_pm["hour"])
        if not 1 <= hour12 <= 12:
            return None
        hour = hour12 % 12 + (12 if am_pm["meridiem"].lower() == "pm" else 0)
        found = am_pm
    else:
        found_24 = _HOUR24_NAME.fullmatch(name) or _FINAL_NAME.fullmatch(name)
        if found_24 is None:
            return None
        hour = int(found_24["hour"])
        found = found_24
    try:
        when = datetime(
            int(found["year"]),
            int(found["month"]),
            int(found["day"]),
            hour,
            int(found["minute"]),
            int(found["second"]),
        )
    except ValueError:
        return None
    prefix = found["prefix"].lower().replace(" ", "-")
    ext = found["ext"].lower()
    return f"{when:%Y/%m/%d}", f"{prefix}-{when:%Y-%m-%d-%H-%M-%S}{ext}"


def _free_path(folder: Path, name: str, src: Path, taken: set[Path]) -> Path:
    """Return a destination that no file and no planned move uses.

    Parameters
    ----------
    folder : Path
        Destination directory.
    name : str
        Preferred file name.
    src : Path
        File being moved. Its own path counts as free.
    taken : set[Path]
        Destinations already planned in this run.

    Returns
    -------
    Path
        ``folder / name``, or the same name with ``-1``, ``-2``, and so on.
    """
    stem = Path(name).stem
    suffix = Path(name).suffix
    candidate = folder / name
    counter = 0
    while candidate in taken or (candidate.exists() and candidate != src):
        counter += 1
        candidate = folder / f"{stem}-{counter}{suffix}"
    return candidate


def _screenshot_candidates(root: Path, *, recursive: bool) -> list[Path]:
    """Return the PNG and MOV files that a run should consider.

    Parameters
    ----------
    root : Path
        Directory to scan.
    recursive : bool
        Scan all subdirectories too, not only the top level.

    Returns
    -------
    list[Path]
        Sorted file paths.
    """
    paths = root.rglob("*") if recursive else root.glob("*")
    return sorted(p for p in paths if p.is_file() and p.suffix.lower() in _SCREENSHOT_SUFFIXES)


def organize_screenshots(
    directory: str,
    *,
    dry_run: bool = False,
    quiet: bool = False,
    recursive: bool = False,
) -> list[str]:
    """Rename screenshots to 24-hour names and move them into dated directories.

    Each name holds its own date and time, so the folder comes from the name,
    not from the file's modification time. Names use zero-padded 24-hour time
    and no AM or PM. A name that would collide gets ``-1``, ``-2``, and so on,
    so no file is overwritten. Names that match no known form stay in place.

    Parameters
    ----------
    directory : str
        Directory that contains the screenshot files.
    dry_run : bool, optional
        Print the planned renames and moves without changing any file.
    quiet : bool, optional
        Suppress output.
    recursive : bool, optional
        Also rename and re-home files in existing ``YYYY/MM/DD`` folders.

    Returns
    -------
    list[str]
        Destination paths of the moved files.

    Raises
    ------
    SystemExit
        If ``directory`` is not a directory.
    """
    root = Path(directory).expanduser()
    if not root.is_dir():
        msg = f"Not a directory: '{root}'"
        raise SystemExit(msg)
    moves: list[tuple[Path, Path]] = []
    taken: set[Path] = set()
    for src in _screenshot_candidates(root, recursive=recursive):
        destination = _screenshot_destination(src.name)
        if destination is None:
            if not quiet:
                print(f"Skipped, unrecognized name: {src}")
            continue
        folder, new_name = destination
        dest = _free_path(root / folder, new_name, src, taken)
        taken.add(dest)
        if dest != src:
            moves.append((src, dest))
    for src, dest in moves:
        if dry_run:
            if not quiet:
                print(f"[dry-run] {src} -> {dest}")
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(src, dest)
    return [str(dest) for _, dest in moves]
