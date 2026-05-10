"""IO module unit tests."""

import json
from pathlib import Path

from koopa.io import extract_conda_bin_names, import_json


def test_import_json(tmp_path: Path) -> None:
    """Test importing a JSON file."""
    data = {"key": "value", "number": 42}
    f = tmp_path / "test.json"
    f.write_text(json.dumps(data))
    result = import_json(str(f))
    assert result == data


def test_import_json_nested(tmp_path: Path) -> None:
    """Test importing nested JSON data."""
    data = {"app": {"version": "1.0", "deps": ["a", "b"]}}
    f = tmp_path / "nested.json"
    f.write_text(json.dumps(data))
    result = import_json(str(f))
    assert result["app"]["version"] == "1.0"
    assert result["app"]["deps"] == ["a", "b"]


def test_extract_conda_bin_names(tmp_path: Path) -> None:
    """Test extracting bin names from conda metadata JSON."""
    data = {
        "files": [
            "bin/python",
            "bin/pip",
            "lib/python3.12/site.py",
            "bin/conda",
            "share/doc/readme.txt",
        ]
    }
    f = tmp_path / "conda-meta.json"
    f.write_text(json.dumps(data))
    result = extract_conda_bin_names(str(f))
    assert sorted(result) == ["conda", "pip", "python"]


def test_extract_conda_bin_names_empty_bins(tmp_path: Path) -> None:
    """Test extraction when no files are in bin/."""
    data = {"files": ["lib/foo.so", "share/info.txt"]}
    f = tmp_path / "meta.json"
    f.write_text(json.dumps(data))
    result = extract_conda_bin_names(str(f))
    assert result == []


def test_extract_conda_bin_names_missing_files_key(tmp_path: Path) -> None:
    """Test extraction raises ValueError when 'files' key missing."""
    data = {"name": "package", "version": "1.0"}
    f = tmp_path / "meta.json"
    f.write_text(json.dumps(data))
    import pytest

    with pytest.raises(ValueError, match="Invalid JSON file"):
        extract_conda_bin_names(str(f))


def test_extract_conda_bin_names_nested_paths(tmp_path: Path) -> None:
    """Test that nested bin paths (bin/subdir/cmd) are excluded."""
    data = {"files": ["bin/tool", "bin/subdir/nested"]}
    f = tmp_path / "meta.json"
    f.write_text(json.dumps(data))
    result = extract_conda_bin_names(str(f))
    assert result == ["tool"]
