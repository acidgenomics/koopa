"""Syntactically valid names.

Uses the external ``syntactic`` package when available, falling back to
built-in implementations.
"""

from re import sub
from unicodedata import combining, normalize

try:
    from syntactic import kebab_case as _ext_kebab_case
    from syntactic import snake_case as _ext_snake_case
except ImportError:
    _ext_kebab_case = None  # type: ignore[assignment]
    _ext_snake_case = None  # type: ignore[assignment]


def _syntactic_engine(string: str) -> str:
    """Reformat string into syntactically valid kebab case."""
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


def kebab_case(string: str) -> str:
    """Kebab case."""
    if _ext_kebab_case is not None:
        result = _ext_kebab_case(string)
        return result[0] if isinstance(result, list) else result
    return _syntactic_engine(string=string)


def remove_accents(string: str) -> str:
    """Remove accents from file metadata.

    See Also
    --------
    - https://stackoverflow.com/a/517974
    """
    nfkd_form = normalize("NFKD", string)
    out = "".join([c for c in nfkd_form if not combining(c)])
    return out


def snake_case(string: str) -> str:
    """Snake case."""
    if _ext_snake_case is not None:
        result = _ext_snake_case(string)
        return result[0] if isinstance(result, list) else result
    string = _syntactic_engine(string=string)
    return string.replace("-", "_")
