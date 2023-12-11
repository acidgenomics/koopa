from os import walk


def list_subdirs(path: str) -> list:
    """
    List subdirectories in a directory.
    Updated 2023-12-11.

    See also:
    - https://stackoverflow.com/questions/141291/
    """
    lst = next(walk(path))[1]
    lst = lst.sort()
    return lst
