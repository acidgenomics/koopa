"""Input/output functions."""

from json import dump, load
from os.path import isfile, join
from re import compile

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


def export_app_json(data: dict) -> None:
    """Sort and write 'app.json' data file."""
    from shutil import which
    from subprocess import run

    sorted_data = dict(sorted(data.items()))
    for key, value in sorted_data.items():
        if isinstance(value, dict):
            sorted_data[key] = dict(sorted(value.items()))
    file = join(koopa_prefix(), "etc/koopa/app.json")
    with open(file, "w", encoding="utf-8") as con:
        dump(sorted_data, con, indent=2, ensure_ascii=False)
        con.write("\n")
    prettier = which("prettier")
    if prettier is not None:
        run([prettier, "--write", file], check=False)


def import_app_json() -> dict:
    """Import 'app.json' data file."""
    file = join(koopa_prefix(), "etc/koopa/app.json")
    assert isfile(file)
    data = import_json(file)
    return data


def import_json(file: str) -> dict:
    """Import a JSON file."""
    with open(file, encoding="utf-8") as con:
        data = load(con)
    return data
