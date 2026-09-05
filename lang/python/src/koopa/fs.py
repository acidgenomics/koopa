"""File system functions."""

from os import scandir, walk
from os.path import basename, join


def list_subdirs(
    path: str, recursive: bool = False, sort: bool = False, basename_only: bool = False
) -> list:
    """List subdirectories in a directory.

    Parameters
    ----------
    path : str
        Directory to list subdirectories of.
    recursive : bool, optional
        Recurse into subdirectories instead of listing only the top level.
    sort : bool, optional
        Sort the returned list.
    basename_only : bool, optional
        Return only the base names instead of full paths.

    Returns
    -------
    list
        Subdirectory paths, or base names if `basename_only` is True.

    Notes
    -----
    https://stackoverflow.com/questions/141291/
    https://stackoverflow.com/questions/800197/
    https://www.techiedelight.com/list-all-subdirectories-in-directory-python/
    For recursive listing, consider using a merge sort approach:
    https://www.freecodecamp.org/news/how-to-sort-recursively-in-python/

    Examples
    --------
    >>> list_subdirs(path="/opt/koopa", recursive=False, basename_only=True)
    """
    if recursive:
        lst = []
        for root, dirs, _ in walk(path):
            for subdir in dirs:
                lst.append(join(root, subdir))
    else:
        lst = [val.path for val in scandir(path) if val.is_dir()]
    if basename_only:
        lst = [basename(val) for val in lst]
    if sort:
        lst.sort()
    return lst
