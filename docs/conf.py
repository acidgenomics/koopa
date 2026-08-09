"""Sphinx configuration for koopa."""

project = "koopa"
author = "Michael Steinbaugh"
copyright = "2018-pres. Acid Genomics LLC"
html_short_title = "koopa"
extensions = ["myst_parser"]
html_theme = "acidgenomics"
html_theme_path = ["_themes"]
html_theme_options = {
    "sitesearch": "koopa.acidgenomics.com",
    "repo_url": "https://github.com/acidgenomics/koopa",
}
html_show_sourcelink = False
html_show_sphinx = False
