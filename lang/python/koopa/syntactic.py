"""
Syntactically valid names.
Updated 2024-04-19.
"""

# FIXME Need to rework to improve consistency with r-syntactic package, after
# we update handling for accented characters and greek character coercion.

from re import sub
from unicodedata import combining, normalize


def _syntactic(string: str) -> str:
    """
    Reformat string into syntactically valid kebab case.
    Updated 2024-04-19.
    """
    assert len(string) > 0
    string = remove_accents(string)
    string = string.lower()
    string = sub(r'([0-9]+)"', r"\1 inch ", string)
    string = string.replace("#", " number ")
    string = string.replace("%", " percent ")
    string = string.replace("&", " and ")
    string = string.replace("+", " plus ")
    string = string.replace("=", " equals ")
    string = string.replace("@", " at ")
    string = string.replace("°", " degrees ")
    string = string.replace("½", " half ")
    string = string.replace("æ", "ae")
    string = string.replace("ð", "d")
    string = string.replace("ø", "o")
    string = string.replace("μ", "mu")
    string = string.replace("✝", " cross ")
    string = string.replace("-", " ")
    string = string.replace("...", " ")
    string = string.replace("/", " ")
    string = string.replace(":", " ")
    string = string.replace("_", " ")
    string = string.replace(" ", "-")
    string = sub(r"[^0-9a-z-]+", r"", string)
    string = sub(r"[-]+", r"-", string)
    string = string.lstrip("-")
    string = string.rstrip("-")
    if not string:
        string = "-"
    return string


def kebab_case(string):
    """
    Kebab case.
    Updated 2023-12-14.
    """
    string = sub(pattern="[^0-9a-zA-Z]+", repl="-", string=string)
    string = string.lower()
    return string


def remove_accents(string: str) -> str:
    """
    Remove accents from file metadata.
    Updated 2024-04-19.

    See also:
    - https://stackoverflow.com/a/517974
    """
    nfkd_form = normalize("NFKD", string)
    out = "".join([c for c in nfkd_form if not combining(c)])
    return out


def snake_case(string):
    """
    Snake case.
    Updated 2023-12-14.
    """
    string = sub(pattern="[^0-9a-zA-Z]+", repl="_", string=string)
    string = string.lower()
    return string
