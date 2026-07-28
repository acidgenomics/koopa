"""Download module unit tests."""

from pathlib import Path

import pytest
from koopa.download import (
    _derive_filename,
    _download_curl,
    _is_sourceforge_url,
    download_with_mirror,
)


def test_derive_filename_simple_url() -> None:
    """Test filename derivation from simple URL."""
    assert _derive_filename("https://example.com/foo.tar.gz") == "foo.tar.gz"


def test_derive_filename_download_path() -> None:
    """Test filename derivation falls back to parent dir basename."""
    result = _derive_filename("https://example.com/releases/v1.0/download")
    assert result == "v1.0"


def test_derive_filename_no_path() -> None:
    """Test filename derivation with bare domain."""
    assert _derive_filename("https://example.com/") == "download"


def test_derive_filename_query_params() -> None:
    """Test filename derivation ignores query parameters."""
    result = _derive_filename("https://example.com/file.zip?token=abc")
    assert result == "file.zip"


def test_download_with_mirror_skips_archive_check_for_non_archive(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A non-archive payload (e.g. a plain .sh script) skips magic-byte validation.

    Regression test: download_with_mirror() used to run archive.is_valid_archive()
    unconditionally, which rejected bash-preexec's bash-preexec.sh (a plain shell
    script, not a compressed archive) as an "invalid archive".
    """
    output = tmp_path / "bash-preexec.sh"

    def fake_download(_url: str, out: str | None = None, **_kwargs: object) -> str:
        assert out is not None
        with open(out, "w") as f:
            f.write("#!/usr/bin/env bash\necho not an archive\n")
        return out

    monkeypatch.setattr("koopa.download.download", fake_download)
    result = download_with_mirror(
        "https://raw.githubusercontent.com/rcaloras/bash-preexec/0.6.0/bash-preexec.sh",
        "bash-preexec",
        "bash-preexec.sh",
        output=str(output),
        skip_koopa_mirror=True,
    )
    assert result == str(output)


def test_download_with_mirror_still_validates_archive_payload(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """An archive-extension payload that fails the magic-byte check still raises.

    Regression test: this is the check that would have caught the corrupt
    tcl-tk mirror object (a SourceForge HTML landing page saved as a tarball).
    """
    output = tmp_path / "pkg-1.0.tar.gz"

    def fake_download(_url: str, out: str | None = None, **_kwargs: object) -> str:
        assert out is not None
        with open(out, "w") as f:
            f.write("<!doctype html><html>not a tarball</html>")
        return out

    monkeypatch.setattr("koopa.download.download", fake_download)
    with pytest.raises(ValueError, match="invalid archive"):
        download_with_mirror(
            "https://example.com/pkg-1.0.tar.gz",
            "pkg",
            "pkg-1.0.tar.gz",
            output=str(output),
            skip_koopa_mirror=True,
        )


@pytest.mark.parametrize(
    "url",
    [
        "https://sourceforge.net/projects/libpng/files/libpng16/1.6.58/libpng-1.6.58.tar.xz/download",
        "https://downloads.sourceforge.net/project/libpng/libpng-1.6.58.tar.xz",
    ],
)
def test_is_sourceforge_url_matches(url: str) -> None:
    """SourceForge's apex domain and subdomains are detected."""
    assert _is_sourceforge_url(url) is True


@pytest.mark.parametrize(
    "url",
    [
        "https://github.com/libgeos/geos/archive/3.14.1.tar.gz",
        "https://notsourceforge.net/files/foo.tar.gz",
    ],
)
def test_is_sourceforge_url_rejects(url: str) -> None:
    """Non-SourceForge hosts, including near-miss domains, are not matched."""
    assert _is_sourceforge_url(url) is False


def test_download_curl_omits_spoofed_user_agent_for_sourceforge(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Curl must not send the spoofed desktop-browser UA to SourceForge.

    Regression test: SourceForge's Cloudflare front 403s koopa's spoofed
    Chrome/Edge _USER_AGENT string on the files/.../download redirect hop
    (confirmed live against multiple SourceForge projects), which broke
    libpng, pcre, swig, tcl-tk, unzip, and zip. Omitting the header (curl's
    own default UA) succeeds.
    """
    monkeypatch.setattr("koopa.download._check_curl", lambda curl_cmd: None)
    captured: dict[str, list[str]] = {}

    def fake_run(args: list[str], **_kwargs: object) -> None:
        captured["args"] = args

    monkeypatch.setattr("koopa.download.subprocess.run", fake_run)
    _download_curl(
        "https://sourceforge.net/projects/infozip/files/Zip%203.x/3.0/zip30.tar.gz/download",
        str(tmp_path / "zip30.tar.gz"),
    )
    assert "--user-agent" not in captured["args"]


def test_download_curl_sends_user_agent_for_non_sourceforge(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Curl still sends the spoofed UA to non-SourceForge hosts (e.g. sourceforge.net.evil.com)."""
    monkeypatch.setattr("koopa.download._check_curl", lambda curl_cmd: None)
    captured: dict[str, list[str]] = {}

    def fake_run(args: list[str], **_kwargs: object) -> None:
        captured["args"] = args

    monkeypatch.setattr("koopa.download.subprocess.run", fake_run)
    _download_curl(
        "https://example.com/pkg-1.0.tar.gz",
        str(tmp_path / "pkg-1.0.tar.gz"),
    )
    assert "--user-agent" in captured["args"]
