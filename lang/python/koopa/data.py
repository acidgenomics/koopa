"""
Utility functions for datatype handling/coercion.
Updated 2024-05-15.
"""


def argsort(object: list, reverse=False) -> list:
    """
    Return the indices that would sort an array.
    Updated 2024-05-15.

    See Also
    --------
    - https://stackoverflow.com/questions/3071415/
    - https://stackoverflow.com/questions/6422700/
    - https://stackoverflow.com/questions/6632188/
    - https://numpy.org/doc/stable/reference/generated/numpy.argsort.html
    - https://docs.python.org/3/howto/sorting.html

    Examples
    --------
    >>> object = ["b", "a", "a", "c", "c", "c"]
    >>> idx1 = argsort(object, reverse=False)
    [1, 2, 0, 3, 4, 5]
    >>> idx2 = argsort(object, reverse=True)
    [3, 4, 5, 0, 1, 2]
    >>> [object[i] for i in idx1]
    ['a', 'a', 'b', 'c', 'c', 'c']
    >>> [object[i] for i in idx2]
    ['c', 'c', 'c', 'b', 'a', 'a']
    """
    iterable = range(len(object))
    key = object.__getitem__
    out = sorted(iterable, key=key, reverse=reverse)
    return out


def flatten(items: list, seqtypes=(list, tuple)) -> list:
    """
    Flatten an arbitrarily nested list.
    Updated 2023-12-14.

    See Also
    --------
    - https://stackoverflow.com/a/10824086

    Examples
    --------
    >>> items = [["a", "b"], ["c", "d"]]
    >>> flatten(items)
    ['a', 'b', 'c', 'd']
    """
    try:
        for i, x in enumerate(items):
            while isinstance(x, seqtypes):
                items[i : i + 1] = x
                x = items[i]
    except IndexError:
        pass
    return items


def unique_pos(object: list) -> list:
    """
    Return the position index of unique values.
    Updated 2024-04-15.

    See Also
    --------
    - https://stackoverflow.com/questions/56830995/

    Examples
    --------
    >>> object = [1, 2, 2, 3, 4, 5, 5, 5]
    >>> unique_pos(object)
    [0, 1, 3, 4, 5]
    """
    out = [object.index(x) for x in sorted(set(object))]
    return out
