"""Update koopa documentation files."""

import re
import sys
from os.path import isfile, join

# Ordered category → known app names mapping.
# Apps with "default": true in app.json that are not listed here will be
# placed in "Miscellaneous" and a warning will be printed.
_APP_CATEGORIES: dict[str, list[str]] = {
    "Shells": [
        "bash",
        "bash-completion",
    ],
    "Core utilities": [
        "bc",
        "coreutils",
        "findutils",
        "gawk",
        "gperf",
        "grep",
        "groff",
        "gzip",
        "make",
        "parallel",
        "patch",
        "perl",
        "pigz",
        "pkg-config",
        "sed",
        "tar",
        "which",
        "xz",
        "zstd",
    ],
    "Compression": [
        "bzip2",
        "p7zip",
    ],
    "File & disk": [
        "du-dust",
        "eza",
        "fd-find",
        "fzf",
        "less",
        "lesspipe",
        "mcfly",
        "ripgrep",
        "tree",
        "zoxide",
    ],
    "Networking": [
        "curl",
        "rclone",
        "rsync",
        "wget",
    ],
    "Version control": [
        "delta",
        "diff-so-fancy",
        "difftastic",
        "gh",
        "git",
        "gitui",
    ],
    "Editors": [
        "nano",
        "neovim",
        "vim",
    ],
    "Terminal utilities": [
        "btop",
        "htop",
        "mdcat",
        "starship",
        "tealdeer",
        "tmux",
    ],
    "Python": [
        "black",
        "bumpver",
        "commitizen",
        "conda",
        "ipython",
        "jupyterlab",
        "poetry",
        "pyflakes",
        "pyright",
        "pytest",
        "python3.13",
        "python3.14",
        "ruff",
        "ruff-lsp",
        "snakefmt",
        "sqlfluff",
        "tqdm",
        "uv",
    ],
    "R": [
        "quarto",
        "r-gfortran",
        "r-xcode-openmp",
        "radian",
    ],
    "Cloud & DevOps": [
        "aws-cli",
        "direnv",
        "editorconfig",
        "openssl",
    ],
    "Miscellaneous": [
        "chezmoi",
        "convmv",
        "dotfiles",
        "gnupg",
        "jq",
        "man-db",
        "shellcheck",
        "units",
    ],
}


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


def _wrap_refs(names: list[str], width: int = 72) -> list[str]:
    """Format app names as reference-style links, wrapped at width chars."""
    refs = [f"[{n}][]" for n in names]
    lines: list[str] = []
    current = ""
    for i, ref in enumerate(refs):
        is_last = i == len(refs) - 1
        token = ref if is_last else ref + ","
        if not current:
            current = token
        elif len(current) + 1 + len(token) <= width:
            current += " " + token
        else:
            lines.append(current)
            current = token
    if current:
        lines.append(current)
    return lines


def _render_default_apps_section(apps: list[str]) -> str:
    """Render the '### Default application stack' markdown section."""
    known: dict[str, str] = {}
    for cat, cat_apps in _APP_CATEGORIES.items():
        for app in cat_apps:
            known[app] = cat

    bucketed: dict[str, list[str]] = {cat: [] for cat in _APP_CATEGORIES}
    uncategorized: list[str] = []
    for app in apps:
        cat = known.get(app)
        if cat is None:
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
        "The following applications are installed by `koopa install-default-apps`:",
    ]
    for cat, cat_apps in bucketed.items():
        if not cat_apps:
            continue
        lines.append("")
        lines.append(f"**{cat}**")
        lines.append("")
        lines.extend(_wrap_refs(cat_apps))
    lines.append("")
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
    with open(index_file, "w", encoding="utf-8") as fh:
        fh.write(new_content)


def update_docs() -> None:
    """Update koopa documentation files."""
    apps = default_app_names()
    update_website_index(apps)
