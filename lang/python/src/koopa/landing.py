"""Shared HTML landing page renderer for python.acidgenomics.com and r.acidgenomics.com.

Both sites serve a generated root index.html from the same steinbaugh.com CSS
chain: a breadcrumb back to acidgenomics.com, a Google site-search form, and a
footer with the license and copyright. Only the package listing and footer
license differ between sites, so the shared skeleton lives here once.
"""

import html
import re

# Section = (heading, entries). entries is (display_name, href, description).
# An empty heading renders no <h2> — used for a single flat, uncategorized list.
_Entry = tuple[str, str, str]
_Section = tuple[str, list[_Entry]]


def _slug(heading: str) -> str:
    """Derive an anchor id from a section heading.

    Lowercases, drops everything but letters/digits/spaces/hyphens, then maps
    spaces to hyphens. Reproduces the existing r.acidgenomics.com anchors,
    e.g. "Import/export" -> "importexport", "RNA sequencing" -> "rna-sequencing".
    """
    stripped = re.sub(r"[^a-z0-9 -]", "", heading.lower())
    return stripped.replace(" ", "-")


def render_landing(
    title: str,
    sections: list[_Section],
    *,
    license_name: str,
    license_url: str,
    copyright_years: str,
    install_note: str | None = None,
) -> str:
    """Render a full landing page as an HTML string.

    Parameters
    ----------
    title
        Page title, also used as the <h1>.
    sections
        Ordered list of (heading, entries) pairs. A section with an empty
        heading renders its entries with no preceding <h2>.
    license_name
        Display text for the license link (e.g. "Apache 2.0").
    license_url
        Target URL for the license link.
    copyright_years
        Footer copyright year range (e.g. "2026-pres.").
    install_note
        Optional extra paragraph rendered between the package list and the
        license footer (e.g. an install command).
    """
    lines = [
        "<!DOCTYPE html>",
        '<html lang="en" id="front">',
        "<head>",
        f"<title>{html.escape(title)}</title>",
        '<link rel="stylesheet" type="text/css" href="css/front.css" />',
        '<meta charset="UTF-8" />',
        '<meta name="viewport" content="width=device-width" />',
        "</head>",
        "",
        "<body>",
        "<nav>",
        '<div id="breadcrumb"><a href="https://acidgenomics.com/">Acid Genomics</a></div>',
        '<form method="get" action="https://www.google.com/search">',
        "<div>",
        '<input type="text" name="q" maxlength="255" placeholder="search" value="" />',
        '<input type="hidden" name="sitesearch" value="acidgenomics.com" />',
        "</div>",
        "</form>",
        "</nav>",
        f"<h1>{html.escape(title)}</h1>",
        "<hr />",
        "",
    ]

    for heading, entries in sections:
        if heading:
            lines.append(f'<h2 id="{_slug(heading)}">{html.escape(heading)}</h2>')
            lines.append("")
        lines.append("<dl>")
        for name, href, description in entries:
            lines.append(f'  <dt><a href="{html.escape(href)}">{html.escape(name)}</a></dt>')
            if description:
                lines.append(f"  <dd>{html.escape(description)}</dd>")
        lines.append("</dl>")
        lines.append("")

    lines.append("<hr />")
    lines.append("")
    if install_note:
        lines.append(f"<p>{install_note}</p>")
        lines.append("")
    lines.append(
        '<p><a href="https://github.com/acidgenomics/">Source code</a> is provided under '
        f'the <a href="{html.escape(license_url)}">{html.escape(license_name)}</a> '
        "license.</p>"
    )
    lines.append("")
    lines.append(f"<p>© {html.escape(copyright_years)} Acid Genomics LLC.</p>")
    lines.append("")
    lines.append("")
    lines.append("</body>")
    lines.append("</html>")
    return "\n".join(lines) + "\n"
