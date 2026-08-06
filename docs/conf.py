"""Sphinx configuration for koopa."""

project = "koopa"
author = "Michael Steinbaugh"
copyright = "2018-pres. Acid Genomics LLC"
extensions = ["myst_parser"]
html_theme = "pydata_sphinx_theme"
html_theme_options = {
    "github_url": "https://github.com/acidgenomics/koopa",
    "logo": {"text": "koopa"},
    "header_links_before_dropdown": 2,
    "secondary_sidebar_items": [],
    "show_toc_level": 0,
    "footer_start": ["copyright"],
    "footer_end": [],
    "article_header_start": [],
}
html_sidebars = {"**": []}
html_css_files = ["https://python.acidgenomics.com/css/sphinx.css"]
html_show_sourcelink = False
