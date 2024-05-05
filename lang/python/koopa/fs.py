"""
File system functions.
Updated 2024-05-05.
"""

from os import scandir, walk
from os.path import basename, join


def list_subdirs(
    path: str, recursive=False, sort=False, basename_only=False
) -> list:
    """
    List subdirectories in a directory.
    Updated 2024-05-05.

    For recursive listing, consider using a merge sort approach:
    https://www.freecodecamp.org/news/how-to-sort-recursively-in-python/

    See also:
    - https://stackoverflow.com/questions/141291/
    - https://stackoverflow.com/questions/800197/
    - https://www.techiedelight.com/list-all-subdirectories-in-directory-python/

    Examples:
    >>> list_subdirs(path="/opt/koopa", recursive=False, basename_only=True)
    """
    if recursive:
        lst = []
        for path, dirs, files in walk(path):
            for subdir in dirs:
                lst.append(join(path, subdir))
    else:
        lst = [val.path for val in scandir(path) if val.is_dir()]
    if basename_only:
        # Alternative approach using `map()`:
        # > lst = list(map(basename, lst))
        lst = [basename(val) for val in lst]
    if sort:
        lst = list.sort()
    return lst
