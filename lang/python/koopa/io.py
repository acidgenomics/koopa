"""
Input/output functions.
Updated 2025-05-03.
"""

from json import load
from os.path import isfile, join
from re import compile

from koopa.os import koopa_prefix


def extract_conda_bin_names(json_file: str) -> list:
    """
    Extract the conda bin names from JSON metadata file.
    Updated 2024-05-03.

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


def import_app_json() -> dict:
    """
    Import 'app.json' data file.
    Updated 2023-12-14.
    """
    file = join(koopa_prefix(), "etc/koopa/app.json")
    assert isfile(file)
    data = import_json(file)
    return data


def import_json(file: str) -> dict:
    """
    Import a JSON file.
    Updated 2023-12-14.
    """
    with open(file, encoding="utf-8") as con:
        data = load(con)
    return data
