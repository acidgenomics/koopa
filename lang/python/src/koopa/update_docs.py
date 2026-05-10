"""Update koopa documentation files."""

import json
import re
import sys
from os.path import isfile, join

_STATIC_REFS: dict[str, str] = {
    "acid genomics": "https://acidgenomics.com/",
    "busybox": "https://busybox.net/",
    "csh": "https://github.com/freebsd/freebsd-src/tree/main/bin/csh/",
    "dash": "https://git.kernel.org/pub/scm/utils/dash/dash.git",
    "docker": "https://www.docker.com/",
    "elvish": "https://elv.sh/",
    "fish": "https://fishshell.com/",
    "ksh93": "http://www.kornshell.com/",
    "linux": "https://www.linuxfoundation.org/",
    "macos": "https://www.apple.com/macos/",
    "mjs": "https://mike.steinbaugh.com/",
    "nushell": "https://www.nushell.sh/",
    "posix": "https://en.wikipedia.org/wiki/POSIX",
    "powershell": "https://learn.microsoft.com/en-us/powershell/",
    "python": "https://www.python.org/",
    "tcsh": "https://en.wikipedia.org/wiki/Tcsh",
    "ubuntu for wsl": "https://ubuntu.com/wsl/",
    "zsh": "https://www.zsh.org/",
}

_EXCLUDE_FROM_DOCS: frozenset[str] = frozenset(
    [
        "r-gfortran",
        "r-xcode-openmp",
    ]
)

def _load_category_order() -> list[str]:
    from koopa.prefix import koopa_prefix

    categories_file = join(koopa_prefix(), "etc", "koopa", "app-categories.json")
    with open(categories_file, encoding="utf-8") as fh:
        groups = json.load(fh)
    return [cat for cats in groups.values() for cat in cats]


def default_app_names() -> list[str]:
    """Return sorted list of default app names from app.json."""
    from koopa.io import import_app_json

    json_data = import_app_json()
    apps = []
    for name, meta in json_data.items():
        if "alias_of" in meta:
            continue
        if meta.get("removed"):
            continue
        if meta.get("default") is True:
            apps.append(name)
    return sorted(apps)


def _wrap_bullet(category: str, names: list[str], width: int = 72) -> str:
    """Format a category bullet with inline app refs, wrapped at width."""
    prefix = f"- **{category}:** "
    indent = "  "
    refs = [f"[{n}][]" for n in names]
    lines: list[str] = []
    current = prefix
    for i, ref in enumerate(refs):
        is_last = i == len(refs) - 1
        token = ref if is_last else ref + ","
        if current == prefix:
            current += token
        elif len(current) + 1 + len(token) <= width:
            current += " " + token
        else:
            lines.append(current)
            current = indent + token
    if current:
        lines.append(current)
    return "\n".join(lines)


def _render_default_apps_section(apps: list[str]) -> str:
    """Render the '### Default application stack' markdown section."""
    from koopa.io import import_app_json

    json_data = import_app_json()
    category_order = _load_category_order()
    bucketed: dict[str, list[str]] = {cat: [] for cat in category_order}
    uncategorized: list[str] = []
    for app in apps:
        if app in _EXCLUDE_FROM_DOCS:
            continue
        cat = json_data.get(app, {}).get("category")
        if cat is None or cat not in bucketed:
            uncategorized.append(app)
            bucketed["Miscellaneous"].append(app)
        else:
            bucketed[cat].append(app)

    if uncategorized:
        print(
            "Warning: uncategorized default apps (added to Miscellaneous): "
            + ", ".join(uncategorized),
            file=sys.stderr,
        )

    lines = [
        "### Default application stack",
        "",
    ]
    for cat, cat_apps in bucketed.items():
        if not cat_apps:
            continue
        lines.append(_wrap_bullet(cat, cat_apps))
    lines.append("")
    return "\n".join(lines) + "\n"


def _render_refs(apps: list[str]) -> str:
    """Render markdown reference-style link definitions from app.json URLs."""
    from koopa.io import import_app_json

    json_data = import_app_json()
    refs: dict[str, str] = {}
    for name in apps:
        meta = json_data.get(name, {})
        url = meta.get("url")
        if isinstance(url, list):
            url = url[0] if url else None
        if url:
            refs[name] = url.rstrip("/")
    for name, url in _STATIC_REFS.items():
        if name not in refs:
            refs[name] = url
    lines = []
    for name in sorted(refs.keys(), key=str.casefold):
        lines.append(f"[{name}]: {refs[name]}")
    return "\n".join(lines) + "\n"


def update_website_index(apps: list[str]) -> None:
    """Update the default app stack section in the website index.md."""
    from koopa.prefix import website_prefix

    index_file = join(website_prefix(), "index.md")
    if not isfile(index_file):
        print(
            f"Error: website index.md not found: {index_file!r}",
            file=sys.stderr,
        )
        sys.exit(1)

    section = _render_default_apps_section(apps)
    with open(index_file, encoding="utf-8") as fh:
        content = fh.read()

    pattern = re.compile(
        r"### Default application stack\n.*?\n(?=## )",
        re.DOTALL,
    )
    if not pattern.search(content):
        print(
            "Error: could not find '### Default application stack' section in index.md.",
            file=sys.stderr,
        )
        sys.exit(1)

    new_content = pattern.sub(section, content)

    ref_pattern = re.compile(
        r"\n\n(\[[^\]]+\]: [^\n]*\n?)+\Z",
    )
    refs_section = _render_refs(apps)
    new_content = ref_pattern.sub("\n\n" + refs_section, new_content)

    with open(index_file, "w", encoding="utf-8") as fh:
        fh.write(new_content)


def update_docs() -> None:
    """Update koopa documentation files."""
    from koopa.generate_man import write_man

    apps = default_app_names()
    update_website_index(apps)
    write_man()
