"""CLI functions intended for printing to console."""

from koopa.app import app_deps, app_revdeps, shared_apps
from koopa.io import extract_conda_bin_names, import_app_json


def print_app_deps(name: str) -> None:
    """Print app dependencies."""
    lst = app_deps(name=name)
    print_list(lst)


def print_app_json(name: str, key: str) -> None:
    """Print values for an app.json key."""
    json_data = import_app_json()
    keys = json_data.keys()
    if name not in keys:
        raise NameError(f"Unsupported app: {name!r}.")
    app_dict = json_data[name]
    if key not in app_dict():
        raise ValueError(f"Invalid key: {key!r}.")
    value = app_dict[key]
    if isinstance(value, list):
        for i in value:
            print(i)
    else:
        print(value)


def print_app_revdeps(name: str, mode: str) -> None:
    """Print app dependencies."""
    lst = app_revdeps(name=name, mode=mode)
    print_list(lst)


def print_conda_bin_names(json_file: str) -> None:
    """Print conda bin names."""
    lst = extract_conda_bin_names(json_file=json_file)
    print_list(lst)


def print_list(obj: list) -> None:
    """Loop across a list and print elements to console."""
    if any(obj):
        for val in obj:
            print(val)


def print_shared_apps(mode: str) -> None:
    """Print shared apps."""
    lst = shared_apps(mode=mode)
    print_list(lst)
