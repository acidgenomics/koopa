"""Landing page renderer unit tests."""

import pytest
from koopa.cran import _CATEGORIES, _generate_landing
from koopa.landing import _slug, render_landing


def test_slug_import_export() -> None:
    """Test slug derivation strips the slash and joins words."""
    assert _slug("Import/export") == "importexport"


def test_slug_multi_word() -> None:
    """Test slug derivation lowercases and hyphenates spaces."""
    assert _slug("Single-cell RNA sequencing") == "single-cell-rna-sequencing"


def test_render_landing_escapes_html() -> None:
    """Test render_landing escapes <, >, and & in names and descriptions."""
    html = render_landing(
        "Title",
        [("", [("Pkg<script>", "pkg/", "A & B <tag>")])],
        license_name="Apache 2.0",
        license_url="https://www.apache.org/licenses/LICENSE-2.0",
        copyright_years="2026-pres.",
    )
    assert "<script>" not in html
    assert "&lt;script&gt;" in html
    assert "A &amp; B &lt;tag&gt;" in html


def test_render_landing_empty_heading_omits_h2() -> None:
    """Test a section with an empty heading renders no <h2> (flat-list mode)."""
    html = render_landing(
        "Title",
        [("", [("pkg", "pkg/", "desc")])],
        license_name="Apache 2.0",
        license_url="https://www.apache.org/licenses/LICENSE-2.0",
        copyright_years="2026-pres.",
    )
    assert "<h2" not in html


def test_render_landing_named_heading_emits_h2_with_slug() -> None:
    """Test a non-empty heading renders an <h2> with the derived slug id."""
    html = render_landing(
        "Title",
        [("Visualization", [("pkg", "pkg/", "desc")])],
        license_name="Apache 2.0",
        license_url="https://www.apache.org/licenses/LICENSE-2.0",
        copyright_years="2026-pres.",
    )
    assert '<h2 id="visualization">Visualization</h2>' in html


def test_render_landing_missing_description_omits_dd() -> None:
    """Test an entry with an empty description renders <dt> with no <dd>."""
    html = render_landing(
        "Title",
        [("", [("pkg", "pkg/", "")])],
        license_name="Apache 2.0",
        license_url="https://www.apache.org/licenses/LICENSE-2.0",
        copyright_years="2026-pres.",
    )
    assert "<dt>" in html
    assert "<dd>" not in html


@pytest.mark.parametrize("category", [name for _, names in _CATEGORIES for name in names])
def test_categories_are_lowercase(category: str) -> None:
    """Test every _CATEGORIES entry is already lowercase (matched by Package.lower())."""
    assert category == category.lower()


def test_generate_landing_preserves_category_order() -> None:
    """Test known packages land under their configured section, in _CATEGORIES order."""
    entries = [
        {"Package": "AcidPlots", "Description": "Functions for plotting genomic data."},
        {"Package": "pipette", "Description": "Input/output functions."},
    ]
    html = _generate_landing(entries)
    # "Import/export" (pipette's section) precedes "Visualization" (AcidPlots's section).
    assert html.index('id="importexport"') < html.index('id="visualization"')


def test_generate_landing_uncategorized_package_warns_and_falls_back(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Test a package absent from _CATEGORIES is appended to Infrastructure and warns."""
    entries = [{"Package": "NewPkg", "Description": "A brand new package."}]
    html = _generate_landing(entries)
    assert '<h2 id="infrastructure">Infrastructure</h2>' in html
    assert "NewPkg" in html
    captured = capsys.readouterr()
    assert "newpkg" in captured.err
    assert "Infrastructure" in captured.err


def test_generate_landing_no_agpl_footer() -> None:
    """Test the generated footer uses Apache 2.0, never the stale AGPLv3 license."""
    entries = [{"Package": "pipette", "Description": "Input/output functions."}]
    html = _generate_landing(entries)
    assert "Apache 2.0" in html
    assert "agpl" not in html.lower()
