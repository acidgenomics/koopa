"""
Utility functions for datatype handling/coercion.
Updated 2024-04-19.
"""


def flatten(items: list, seqtypes=(list, tuple)) -> list:
    """
    Flatten an arbitrarily nested list.
    Updated 2023-12-14.

    See also:
    - https://stackoverflow.com/a/10824086
    """
    try:
        for i, x in enumerate(items):
            while isinstance(x, seqtypes):
                items[i : i + 1] = x
                x = items[i]
    except IndexError:
        pass
    return items
