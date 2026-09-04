"""CLI functions intended for printing to console."""

from koopa.app import shared_apps


def print_list(obj: list) -> None:
    """Loop across a list and print elements to console.

    Parameters
    ----------
    obj : list
        List whose elements are printed one per line.
    """
    if any(obj):
        for val in obj:
            print(val)


def print_shared_apps(mode: str) -> None:
    """Print shared apps.

    Parameters
    ----------
    mode : str
        Filter mode, either ``"all"`` or ``"default"``.
    """
    lst = shared_apps(mode=mode)
    print_list(lst)
