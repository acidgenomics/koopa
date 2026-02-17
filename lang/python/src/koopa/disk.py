"""Disk usage analysis functions.

Converted from Bash/POSIX shell functions: disk-gb-free, disk-gb-total,
disk-gb-used, disk-pct-free, disk-pct-used, df2, find-large-files,
find-large-dirs, etc.
"""

from __future__ import annotations

import contextlib
import os
import shutil


def disk_gb_free(path: str = "/") -> float:
    """Get free disk space in GB."""
    usage = shutil.disk_usage(path)
    return usage.free / (1024**3)


def disk_gb_total(path: str = "/") -> float:
    """Get total disk space in GB."""
    usage = shutil.disk_usage(path)
    return usage.total / (1024**3)


def disk_gb_used(path: str = "/") -> float:
    """Get used disk space in GB."""
    usage = shutil.disk_usage(path)
    return usage.used / (1024**3)


def disk_pct_free(path: str = "/") -> float:
    """Get free disk space as a percentage."""
    usage = shutil.disk_usage(path)
    return (usage.free / usage.total) * 100


def disk_pct_used(path: str = "/") -> float:
    """Get used disk space as a percentage."""
    usage = shutil.disk_usage(path)
    return (usage.used / usage.total) * 100


def df2(path: str = "/") -> dict[str, str]:
    """Get disk usage summary as a dictionary."""
    usage = shutil.disk_usage(path)
    return {
        "path": path,
        "total_gb": f"{usage.total / (1024**3):.1f}",
        "used_gb": f"{usage.used / (1024**3):.1f}",
        "free_gb": f"{usage.free / (1024**3):.1f}",
        "pct_used": f"{(usage.used / usage.total) * 100:.1f}%",
    }


def find_large_files(
    dir_path: str,
    *,
    min_size_mb: float = 100,
    max_results: int = 50,
) -> list[tuple[str, float]]:
    """Find files larger than a threshold (in MB)."""
    large: list[tuple[str, float]] = []
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
    return large[:max_results]


def find_large_dirs(
    dir_path: str,
    *,
    min_size_mb: float = 100,
    max_depth: int | None = None,
) -> list[tuple[str, float]]:
    """Find directories larger than a threshold (in MB)."""
    dir_sizes: dict[str, float] = {}
    for root, _dirs, files in os.walk(dir_path):
        if max_depth is not None:
            depth = root.replace(dir_path, "").count(os.sep)
            if depth > max_depth:
                continue
        total = 0.0
        for f in files:
            full = os.path.join(root, f)
            with contextlib.suppress(OSError):
                total += os.path.getsize(full)
        dir_sizes[root] = total / (1024 * 1024)
    large = [(d, s) for d, s in dir_sizes.items() if s >= min_size_mb]
    large.sort(key=lambda x: x[1], reverse=True)
    return large
