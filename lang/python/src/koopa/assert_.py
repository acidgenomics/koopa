"""Assertion functions for validation.

Converted from Bash assert functions: assert-has-args, assert-is-dir,
assert-is-file, assert-is-admin, assert-is-installed, etc.
"""

from __future__ import annotations

import os
import re
import shutil

from koopa.system import is_admin


class AssertionError(Exception):
    """Custom assertion error for koopa."""

    pass


def assert_has_args(args: list | tuple) -> None:
    """Assert that arguments were provided."""
    if not args:
        msg = "Arguments are required."
        raise AssertionError(msg)


def assert_has_args_eq(args: list | tuple, n: int) -> None:
    """Assert exactly n arguments."""
    if len(args) != n:
        msg = f"Expected {n} args, got {len(args)}."
        raise AssertionError(msg)


def assert_has_args_ge(args: list | tuple, n: int) -> None:
    """Assert at least n arguments."""
    if len(args) < n:
        msg = f"Expected >= {n} args, got {len(args)}."
        raise AssertionError(msg)


def assert_has_args_le(args: list | tuple, n: int) -> None:
    """Assert at most n arguments."""
    if len(args) > n:
        msg = f"Expected <= {n} args, got {len(args)}."
        raise AssertionError(msg)


def assert_has_no_args(args: list | tuple) -> None:
    """Assert no arguments."""
    if args:
        msg = "No arguments expected."
        raise AssertionError(msg)


def assert_is_dir(*paths: str) -> None:
    """Assert paths are directories."""
    for p in paths:
        if not os.path.isdir(p):
            msg = f"Not a directory: {p}"
            raise AssertionError(msg)


def assert_is_file(*paths: str) -> None:
    """Assert paths are files."""
    for p in paths:
        if not os.path.isfile(p):
            msg = f"Not a file: {p}"
            raise AssertionError(msg)


def assert_is_executable(*paths: str) -> None:
    """Assert paths are executable."""
    for p in paths:
        if not os.access(p, os.X_OK):
            msg = f"Not executable: {p}"
            raise AssertionError(msg)


def assert_is_existing(*paths: str) -> None:
    """Assert paths exist."""
    for p in paths:
        if not os.path.exists(p):
            msg = f"Does not exist: {p}"
            raise AssertionError(msg)


def assert_is_non_existing(*paths: str) -> None:
    """Assert paths do not exist."""
    for p in paths:
        if os.path.exists(p):
            msg = f"Already exists: {p}"
            raise AssertionError(msg)


def assert_is_symlink(*paths: str) -> None:
    """Assert paths are symlinks."""
    for p in paths:
        if not os.path.islink(p):
            msg = f"Not a symlink: {p}"
            raise AssertionError(msg)


def assert_is_not_symlink(*paths: str) -> None:
    """Assert paths are not symlinks."""
    for p in paths:
        if os.path.islink(p):
            msg = f"Is a symlink: {p}"
            raise AssertionError(msg)


def assert_is_not_dir(*paths: str) -> None:
    """Assert paths are not directories."""
    for p in paths:
        if os.path.isdir(p):
            msg = f"Is a directory: {p}"
            raise AssertionError(msg)


def assert_is_not_file(*paths: str) -> None:
    """Assert paths are not files."""
    for p in paths:
        if os.path.isfile(p):
            msg = f"Is a file: {p}"
            raise AssertionError(msg)


def assert_is_readable(*paths: str) -> None:
    """Assert paths are readable."""
    for p in paths:
        if not os.access(p, os.R_OK):
            msg = f"Not readable: {p}"
            raise AssertionError(msg)


def assert_is_writable(*paths: str) -> None:
    """Assert paths are writable."""
    for p in paths:
        if not os.access(p, os.W_OK):
            msg = f"Not writable: {p}"
            raise AssertionError(msg)


def assert_is_owner(*paths: str) -> None:
    """Assert current user owns the paths."""
    uid = os.geteuid()
    for p in paths:
        if os.path.exists(p) and os.stat(p).st_uid != uid:
            msg = f"Not owned by current user: {p}"
            raise AssertionError(msg)


def assert_is_admin() -> None:
    """Assert user has admin privileges."""
    if not is_admin():
        msg = "Admin privileges required."
        raise AssertionError(msg)


def assert_is_root() -> None:
    """Assert user is root."""
    if os.geteuid() != 0:
        msg = "Root privileges required."
        raise AssertionError(msg)


def assert_is_not_root() -> None:
    """Assert user is not root."""
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise AssertionError(msg)


def assert_is_installed(*names: str) -> None:
    """Assert programs are installed."""
    for name in names:
        if not shutil.which(name):
            msg = f"Not installed: {name}"
            raise AssertionError(msg)


def assert_is_not_installed(*names: str) -> None:
    """Assert programs are not installed."""
    for name in names:
        if shutil.which(name):
            msg = f"Already installed: {name}"
            raise AssertionError(msg)


def assert_is_set(*values: str | None) -> None:
    """Assert values are set (non-empty)."""
    for v in values:
        if not v:
            msg = "Value is not set."
            raise AssertionError(msg)


def assert_is_matching_fixed(string: str, pattern: str) -> None:
    """Assert fixed pattern match."""
    if pattern not in string:
        msg = f"String does not contain '{pattern}'."
        raise AssertionError(msg)


def assert_is_matching_regex(string: str, pattern: str) -> None:
    """Assert regex pattern match."""
    if not re.search(pattern, string):
        msg = f"String does not match pattern '{pattern}'."
        raise AssertionError(msg)


def assert_is_git_repo(path: str = ".") -> None:
    """Assert path is a git repository."""
    git_dir = os.path.join(path, ".git")
    if not os.path.isdir(git_dir):
        msg = f"Not a git repository: {path}"
        raise AssertionError(msg)


def assert_is_nonzero_file(path: str) -> None:
    """Assert file exists and is non-empty."""
    if not os.path.isfile(path) or os.path.getsize(path) == 0:
        msg = f"File is empty or missing: {path}"
        raise AssertionError(msg)


def assert_is_compressed_file(path: str) -> None:
    """Assert file has a compressed extension."""
    exts = (".gz", ".bz2", ".xz", ".zst", ".lz4", ".zip", ".7z", ".tar")
    if not any(path.lower().endswith(e) for e in exts):
        msg = f"Not a compressed file: {path}"
        raise AssertionError(msg)


def assert_is_not_compressed_file(path: str) -> None:
    """Assert file does not have a compressed extension."""
    exts = (".gz", ".bz2", ".xz", ".zst", ".lz4", ".zip", ".7z")
    if any(path.lower().endswith(e) for e in exts):
        msg = f"Is a compressed file: {path}"
        raise AssertionError(msg)


def assert_has_file_ext(path: str) -> None:
    """Assert file has an extension."""
    _, ext = os.path.splitext(path)
    if not ext:
        msg = f"File has no extension: {path}"
        raise AssertionError(msg)


def assert_is_array_non_empty(arr: list | tuple) -> None:
    """Assert array is non-empty."""
    if not arr:
        msg = "Array is empty."
        raise AssertionError(msg)


def assert_are_identical(a: str, b: str) -> None:
    """Assert two values are identical."""
    if a != b:
        msg = f"Values differ: '{a}' != '{b}'."
        raise AssertionError(msg)


def assert_are_not_identical(a: str, b: str) -> None:
    """Assert two values differ."""
    if a == b:
        msg = f"Values are identical: '{a}'."
        raise AssertionError(msg)


def assert_has_no_flags(args: list | tuple) -> None:
    """Assert no flags (--) in args."""
    for arg in args:
        if str(arg).startswith("-"):
            msg = f"Unexpected flag: {arg}"
            raise AssertionError(msg)
