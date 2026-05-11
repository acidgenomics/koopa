"""Input/output functions."""

import contextlib
import tempfile
from json import dump, load, loads
from os import rename
from os.path import dirname, isfile, join
from re import compile
from time import sleep

from koopa.os import koopa_prefix


def extract_conda_bin_names(json_file: str) -> list:
    """Extract the conda bin names from JSON metadata file.

    Examples
    --------
    json_file='/opt/koopa/opt/anaconda/conda-meta/conda-*.json'
    conda_bin_names(json_file=json_file)
    """
    json_data = import_json(json_file)
    keys = json_data.keys()
    if "files" not in keys:
        raise ValueError(f"Invalid JSON file: {json_file!r}.")
    file_list = json_data["files"]
    bin_names = []
    pattern = compile(r"^bin/([^/]+)$")
    for file in file_list:
        match = pattern.match(file)
        if match:
            bin_name = match.group(1)
            bin_names.append(bin_name)
    return bin_names


def _atomic_json_write(file: str, data: dict) -> None:
    """Write JSON data atomically via temp file + rename."""
    dir_ = dirname(file)
    fd, tmp_path = tempfile.mkstemp(dir=dir_, suffix=".json.tmp")
    try:
        with open(fd, "w", encoding="utf-8") as con:
            dump(data, con, indent=2, ensure_ascii=False)
            con.write("\n")
        rename(tmp_path, file)
    except BaseException:
        with contextlib.suppress(OSError):
            import os

            os.unlink(tmp_path)
        raise


def export_app_json(data: dict) -> None:
    """Sort and write 'app.json' data file."""
    from shutil import which
    from subprocess import run

    sorted_data = dict(sorted(data.items()))
    for key, value in sorted_data.items():
        if isinstance(value, dict):
            sorted_data[key] = dict(sorted(value.items()))
    file = join(koopa_prefix(), "etc/koopa/app.json")
    _atomic_json_write(file, sorted_data)
    prettier = which("prettier")
    if prettier is not None:
        run([prettier, "--log-level", "silent", "--write", file], check=True)
        with open(file, encoding="utf-8") as con:
            normalized = load(con)
        sorted_normalized = dict(sorted(normalized.items()))
        for key, value in sorted_normalized.items():
            if isinstance(value, dict):
                sorted_normalized[key] = dict(sorted(value.items()))
        _atomic_json_write(file, sorted_normalized)


def import_app_json() -> dict:
    """Import 'app.json' data file."""
    file = join(koopa_prefix(), "etc/koopa/app.json")
    assert isfile(file)
    data = import_json(file)
    return data


def import_json(file: str) -> dict:
    """Import a JSON file with retry on parse failure."""
    last_exc: ValueError | None = None
    for attempt in range(3):
        with open(file, encoding="utf-8") as con:
            content = con.read()
        try:
            return loads(content)
        except ValueError as exc:
            last_exc = exc
            if attempt < 2:
                sleep(0.2 * (attempt + 1))
    assert last_exc is not None
    raise last_exc
