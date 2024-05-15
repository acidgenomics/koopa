"""
Utility functions for datatype handling/coercion.
Updated 2024-05-15.
"""


def argsort(object, reverse=False):
    """
    Return the indices that would sort an array.
    Updated 2024-05-15.

    See also:
    - https://stackoverflow.com/questions/3071415/
    - https://numpy.org/doc/stable/reference/generated/numpy.argsort.html
    - https://docs.python.org/3/howto/sorting.html
    """
    iterable = range(len(object))
    key = object.__getitem__
    out = sorted(iterable, key=key, reverse=reverse)
    return out


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
