"""Text processing functions.

Converted from Bash/POSIX shell functions: camel-case, kebab-case, snake-case,
find-and-replace, detab, entab, eol-lf, sort-lines, head, tail, grep, nchar,
nlines, autopad-zeros, find-files-without-line-ending, etc.
"""

from __future__ import annotations

import os
import re
from pathlib import Path


def camel_case(string: str) -> str:
    """Convert a string to camelCase."""
    parts = re.split(r"[-_ .]+", string)
    if not parts:
        return string
    return parts[0].lower() + "".join(w.capitalize() for w in parts[1:])


def pascal_case(string: str) -> str:
    """Convert a string to PascalCase."""
    parts = re.split(r"[-_ .]+", string)
    return "".join(w.capitalize() for w in parts)


def kebab_case(string: str) -> str:
    """Convert a string to kebab-case."""
    s = re.sub(r"([A-Z])", r"-\1", string)
    s = re.sub(r"[_ .]+", "-", s)
    s = re.sub(r"-+", "-", s)
    return s.strip("-").lower()


def snake_case(string: str) -> str:
    """Convert a string to snake_case."""
    s = re.sub(r"([A-Z])", r"_\1", string)
    s = re.sub(r"[- .]+", "_", s)
    s = re.sub(r"_+", "_", s)
    return s.strip("_").lower()


def find_and_replace_in_file(
    path: str,
    pattern: str,
    replacement: str,
    *,
    fixed: bool = False,
) -> None:
    """Find and replace text in a file."""
    text = Path(path).read_text()
    text = text.replace(pattern, replacement) if fixed else re.sub(pattern, replacement, text)
    Path(path).write_text(text)


def detab(path: str, *, tab_size: int = 4) -> None:
    """Convert tabs to spaces in a file."""
    text = Path(path).read_text()
    text = text.expandtabs(tab_size)
    Path(path).write_text(text)


def entab(path: str, *, tab_size: int = 4) -> None:
    """Convert spaces to tabs in a file."""
    text = Path(path).read_text()
    text = text.replace(" " * tab_size, "\t")
    Path(path).write_text(text)


def eol_lf(path: str) -> None:
    """Convert line endings to LF (Unix)."""
    text = Path(path).read_bytes()
    text = text.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    Path(path).write_bytes(text)


def sort_lines(path: str, *, unique: bool = False) -> None:
    """Sort lines in a file."""
    lines = Path(path).read_text().splitlines()
    lines.sort()
    if unique:
        lines = list(dict.fromkeys(lines))
    Path(path).write_text("\n".join(lines) + "\n")


def head(path: str, n: int = 10) -> list[str]:
    """Return the first n lines of a file."""
    with open(path) as f:
        return [next(f).rstrip("\n") for _ in range(n)]


def tail(path: str, n: int = 10) -> list[str]:
    """Return the last n lines of a file."""
    lines = Path(path).read_text().splitlines()
    return lines[-n:]


def grep(pattern: str, path: str, *, fixed: bool = False) -> list[str]:
    """Search for pattern in a file and return matching lines."""
    lines = Path(path).read_text().splitlines()
    if fixed:
        return [line for line in lines if pattern in line]
    rx = re.compile(pattern)
    return [line for line in lines if rx.search(line)]


def grep_string(pattern: str, string: str, *, fixed: bool = False) -> list[str]:
    """Search for pattern in a string and return matching lines."""
    lines = string.splitlines()
    if fixed:
        return [line for line in lines if pattern in line]
    rx = re.compile(pattern)
    return [line for line in lines if rx.search(line)]


def nchar(string: str) -> int:
    """Return character count of a string."""
    return len(string)


def nlines(path: str) -> int:
    """Count lines in a file."""
    with open(path) as f:
        return sum(1 for _ in f)


def to_string(items: list, *, sep: str = " ") -> str:
    """Convert a list to a string."""
    return sep.join(str(x) for x in items)


def autopad_zeros(
    dir_path: str, *, prefix: str = "", dry_run: bool = False
) -> list[tuple[str, str]]:
    """Auto-pad numeric filenames with leading zeros.

    Renames files like 1.txt, 2.txt, ..., 100.txt to 001.txt, 002.txt, etc.
    """
    p = Path(dir_path)
    files = sorted(f for f in p.iterdir() if f.is_file())
    numeric = []
    for f in files:
        stem = f.stem
        if prefix:
            stem = stem.removeprefix(prefix)
        if stem.isdigit():
            numeric.append((f, int(stem)))
    if not numeric:
        return []
    max_digits = len(str(max(n for _, n in numeric)))
    renames = []
    for f, n in numeric:
        new_stem = prefix + str(n).zfill(max_digits)
        new_name = new_stem + f.suffix
        new_path = f.parent / new_name
        if f.name != new_name:
            renames.append((str(f), str(new_path)))
            if not dry_run:
                f.rename(new_path)
    return renames


def find_files_without_line_ending(dir_path: str) -> list[str]:
    """Find files that don't end with a newline."""
    result = []
    for root, _, files in os.walk(dir_path):
        for f in files:
            full = os.path.join(root, f)
            try:
                data = Path(full).read_bytes()
                if data and not data.endswith(b"\n"):
                    result.append(full)
            except OSError, UnicodeDecodeError:
                pass
    return result
