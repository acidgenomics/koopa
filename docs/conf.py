"""Sphinx configuration for koopa."""

from pathlib import Path

# Single source of truth for the ASCII mark (also read by `koopa system info`,
# see cli_system.py) -- not duplicated into the docs tree.
_ascii_turtle = (
    (Path(__file__).parent.parent / "etc" / "koopa" / "ascii-turtle.txt")
    .read_text(encoding="utf-8")
    .rstrip("\n")
)

project = "koopa"
author = "Michael Steinbaugh"
copyright = "2018-pres. Acid Genomics LLC"
html_title = "koopa"
extensions = ["myst_parser"]
myst_heading_anchors = 3
html_theme = "acidgenomics"
html_theme_path = ["_themes"]
html_theme_options = {
    "sitesearch": "koopa.acidgenomics.com",
    "repo_url": "https://github.com/acidgenomics/koopa",
    "copyright_start_year": "2018",
    "license_name": "Apache 2.0",
    "license_url": "https://www.apache.org/licenses/LICENSE-2.0",
    "license_file_url": "https://github.com/acidgenomics/koopa/blob/main/LICENSE",
    "header_ascii": _ascii_turtle,
    "tagline": "Shell bootloader for data science.",
}
html_static_path = ["_static"]
html_show_sourcelink = False
html_show_sphinx = False
