"""Download module unit tests."""

import subprocess
from pathlib import Path

import pytest
from koopa.download import (
    _blocks_spoofed_user_agent,
    _derive_filename,
    _download_curl,
    _gnu_mirrors,
    _gnupg_mirrors,
    _savannah_mirrors,
    download,
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


def test_download_with_mirror_vendor_only_skips_public_hosts(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """vendor_only tries only the vendor mirror, never the primary URL.

    Regression test: download_with_mirror() used to try primary_url (and the
    GNU/Savannah/koopa mirrors) before falling back to the vendor mirror even
    under vendor_only priority, defeating the point of an airgapped mirror.
    """
    output = tmp_path / "pkg-1.0.tar.gz"
    attempted: list[str] = []

    def fake_download(url: str, out: str | None = None, **_kwargs: object) -> str:
        attempted.append(url)
        assert out is not None
        with open(out, "wb") as f:
            f.write(b"\x1f\x8b" + b"\x00" * 8)  # minimal gzip magic bytes
        return out

    monkeypatch.setattr("koopa.download.download", fake_download)
    monkeypatch.setattr("koopa.vendor.vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr("koopa.vendor.vendor_pull_priority", lambda: "vendor_only")
    monkeypatch.setattr(
        "koopa.vendor.vendor_download_src",
        lambda _name, _filename: "https://mirror.example.com/pkg-1.0.tar.gz",
    )
    result = download_with_mirror(
        "https://example.com/pkg-1.0.tar.gz",
        "pkg",
        "pkg-1.0.tar.gz",
        output=str(output),
    )
    assert result == str(output)
    assert attempted == ["https://mirror.example.com/pkg-1.0.tar.gz"]


def test_download_with_mirror_vendor_only_without_vendor_url_raises(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """vendor_only with no vendor mirror URL available raises, contacting nothing."""
    output = tmp_path / "pkg-1.0.tar.gz"
    attempted: list[str] = []

    def fake_download(url: str, out: str | None = None, **_kwargs: object) -> str:
        attempted.append(url)
        return out or ""

    monkeypatch.setattr("koopa.download.download", fake_download)
    monkeypatch.setattr("koopa.vendor.vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr("koopa.vendor.vendor_pull_priority", lambda: "vendor_only")
    monkeypatch.setattr("koopa.vendor.vendor_download_src", lambda _name, _filename: None)
    with pytest.raises(FileNotFoundError, match="vendor_only"):
        download_with_mirror(
            "https://example.com/pkg-1.0.tar.gz",
            "pkg",
            "pkg-1.0.tar.gz",
            output=str(output),
        )
    assert attempted == []


def test_download_with_mirror_vendor_first_tries_primary_before_vendor(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """vendor_first (the default) still tries the primary URL before the vendor mirror."""
    output = tmp_path / "pkg-1.0.tar.gz"
    attempted: list[str] = []

    def fake_download(url: str, out: str | None = None, **_kwargs: object) -> str:
        attempted.append(url)
        if url == "https://example.com/pkg-1.0.tar.gz":
            raise RuntimeError("primary unreachable")
        assert out is not None
        with open(out, "wb") as f:
            f.write(b"\x1f\x8b" + b"\x00" * 8)
        return out

    monkeypatch.setattr("koopa.download.download", fake_download)
    monkeypatch.setattr("koopa.vendor.vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr("koopa.vendor.vendor_pull_priority", lambda: "vendor_first")
    monkeypatch.setattr(
        "koopa.vendor.vendor_download_src",
        lambda _name, _filename: "https://mirror.example.com/pkg-1.0.tar.gz",
    )
    result = download_with_mirror(
        "https://example.com/pkg-1.0.tar.gz",
        "pkg",
        "pkg-1.0.tar.gz",
        output=str(output),
        skip_koopa_mirror=True,
    )
    assert result == str(output)
    assert attempted[0] == "https://example.com/pkg-1.0.tar.gz"
    assert "https://mirror.example.com/pkg-1.0.tar.gz" in attempted


def test_download_with_mirror_vendor_only_succeeds_via_remote_rewrite(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """vendor_only with no direct src-mirror URL still succeeds via a remote-proxy rewrite.

    Regression test: download_with_mirror() used to raise FileNotFoundError
    under vendor_only whenever vendor_download_src() returned None, even if a
    configured 'http.remotes' rewrite of a public URL was available.
    """
    output = tmp_path / "pkg-1.0.tar.gz"
    attempted: list[str] = []

    def fake_download(url: str, out: str | None = None, **_kwargs: object) -> str:
        attempted.append(url)
        assert out is not None
        with open(out, "wb") as f:
            f.write(b"\x1f\x8b" + b"\x00" * 8)
        return out

    monkeypatch.setattr("koopa.download.download", fake_download)
    monkeypatch.setattr("koopa.vendor.vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr("koopa.vendor.vendor_pull_priority", lambda: "vendor_only")
    monkeypatch.setattr("koopa.vendor.vendor_download_src", lambda _name, _filename: None)
    monkeypatch.setattr(
        "koopa.vendor.vendor_rewrite_url",
        lambda url: url.replace("https://example.com", "https://mirror.example.com/github-remote"),
    )
    result = download_with_mirror(
        "https://example.com/pkg-1.0.tar.gz",
        "pkg",
        "pkg-1.0.tar.gz",
        output=str(output),
    )
    assert result == str(output)
    assert attempted == ["https://mirror.example.com/github-remote/pkg-1.0.tar.gz"]


def test_download_with_mirror_vendor_first_includes_remote_rewrite(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """vendor_first also tries a remote-proxy rewrite of the primary URL as a fallback."""
    output = tmp_path / "pkg-1.0.tar.gz"
    attempted: list[str] = []

    def fake_download(url: str, out: str | None = None, **_kwargs: object) -> str:
        attempted.append(url)
        if url != "https://mirror.example.com/github-remote/pkg-1.0.tar.gz":
            raise RuntimeError("unreachable")
        assert out is not None
        with open(out, "wb") as f:
            f.write(b"\x1f\x8b" + b"\x00" * 8)
        return out

    monkeypatch.setattr("koopa.download.download", fake_download)
    monkeypatch.setattr("koopa.vendor.vendor_config", lambda: {"enabled": True})
    monkeypatch.setattr("koopa.vendor.vendor_pull_priority", lambda: "vendor_first")
    monkeypatch.setattr("koopa.vendor.vendor_download_src", lambda _name, _filename: None)
    monkeypatch.setattr(
        "koopa.vendor.vendor_rewrite_url",
        lambda url: url.replace("https://example.com", "https://mirror.example.com/github-remote"),
    )
    result = download_with_mirror(
        "https://example.com/pkg-1.0.tar.gz",
        "pkg",
        "pkg-1.0.tar.gz",
        output=str(output),
        skip_koopa_mirror=True,
    )
    assert result == str(output)
    assert attempted[0] == "https://example.com/pkg-1.0.tar.gz"
    assert "https://mirror.example.com/github-remote/pkg-1.0.tar.gz" in attempted


@pytest.mark.parametrize(
    "url",
    [
        "https://sourceforge.net/projects/libpng/files/libpng16/1.6.58/libpng-1.6.58.tar.xz/download",
        "https://downloads.sourceforge.net/project/libpng/libpng-1.6.58.tar.xz",
        "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.16.0.tar.xz",
    ],
)
def test_blocks_spoofed_user_agent_matches(url: str) -> None:
    """SourceForge's apex domain, subdomains, and www.freedesktop.org are detected."""
    assert _blocks_spoofed_user_agent(url) is True


@pytest.mark.parametrize(
    "url",
    [
        "https://github.com/libgeos/geos/archive/3.14.1.tar.gz",
        "https://notsourceforge.net/files/foo.tar.gz",
        "https://xorg.freedesktop.org/archive/individual/lib/libX11-1.8.tar.xz",
    ],
)
def test_blocks_spoofed_user_agent_rejects(url: str) -> None:
    """Non-matching hosts, including near-miss domains, are not matched."""
    assert _blocks_spoofed_user_agent(url) is False


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


def test_download_curl_quiet_folds_stderr_into_exception(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Quiet mode captures curl's stderr and raises it instead of leaking it.

    Regression test: a bare `curl: (28) Connection timed out ...` line used to
    leak to the terminal from a quiet, fully-recovered mirror-upload attempt,
    with no indication of which app or URL stalled.
    """
    monkeypatch.setattr("koopa.download._check_curl", lambda curl_cmd: None)

    def fake_run(args: list[str], **_kwargs: object) -> None:
        raise subprocess.CalledProcessError(
            28, args, stderr="curl: (28) Connection timed out after 10002 milliseconds\n"
        )

    monkeypatch.setattr("koopa.download.subprocess.run", fake_run)
    with pytest.raises(RuntimeError, match=r"curl exit 28.*Connection timed out"):
        _download_curl(
            "https://example.com/pkg-1.0.tar.gz",
            str(tmp_path / "pkg-1.0.tar.gz"),
            quiet=True,
        )


def test_download_reports_url_when_falling_back(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A recovered fallback names the URL and next transport, even in quiet mode.

    Regression test: quiet=True suppressed the "Downloading ..." line and the
    per-attempt failure, so a stall that self-healed via the /usr/bin/curl
    fallback was invisible except for the leaked bare curl error.
    """
    output = tmp_path / "pkg-1.0.tar.gz"

    def fake_download_curl(
        _url: str, out: str, *, curl_cmd: str = "curl", **_kwargs: object
    ) -> None:
        if curl_cmd == "curl":
            raise RuntimeError("curl exit 28: Connection timed out")
        Path(out).write_text("payload")

    monkeypatch.setattr("koopa.download._download_curl", fake_download_curl)
    result = download(
        "https://example.com/pkg-1.0.tar.gz",
        str(output),
        quiet=True,
    )
    assert result == str(output)
    err = capsys.readouterr().err
    assert "pkg-1.0.tar.gz" in err
    assert "/usr/bin/curl" in err


def test_gnu_mirrors_preserves_versioned_subdirectory() -> None:
    """The gcc tarball lives in a versioned subdirectory, not flat under its name.

    Regression test: _gnu_mirrors() used to compose 'gcc/gcc-16.2.0.tar.xz'
    (name/filename), 404ing on every mirror, because gcc's real path is
    'gcc/gcc-16.2.0/gcc-16.2.0.tar.xz'. Deriving the relative path from the
    primary URL instead preserves the subdirectory.
    """
    mirrors = _gnu_mirrors("https://mirrors.kernel.org/gnu/gcc/gcc-16.2.0/gcc-16.2.0.tar.xz")
    assert mirrors
    for url in mirrors:
        assert url.endswith("/gcc/gcc-16.2.0/gcc-16.2.0.tar.xz")


def test_gnu_mirrors_maps_wget2_to_wget_parent_directory() -> None:
    """wget2's tarball lives under the 'wget' parent directory, not 'wget2'.

    Regression test: composing 'wget2/wget2-2.2.1.tar.gz' 404s; the real path is
    'wget/wget2-2.2.1.tar.gz'.
    """
    mirrors = _gnu_mirrors("https://mirrors.kernel.org/gnu/wget/wget2-2.2.1.tar.gz")
    assert mirrors
    for url in mirrors:
        assert url.endswith("/wget/wget2-2.2.1.tar.gz")


def test_gnu_mirrors_flat_app_unchanged() -> None:
    """A flat app (no versioned subdirectory) still resolves correctly."""
    mirrors = _gnu_mirrors("https://mirrors.kernel.org/gnu/sed/sed-4.10.tar.gz")
    assert mirrors
    for url in mirrors:
        assert url.endswith("/sed/sed-4.10.tar.gz")


def test_gnu_mirrors_ftp_gnu_org_prefix_not_doubled() -> None:
    """ftp.gnu.org URLs are rooted at '/gnu/<path>'; the leading 'gnu/' must be stripped once."""
    mirrors = _gnu_mirrors("https://ftp.gnu.org/gnu/mpc/mpc-1.4.1.tar.xz")
    assert mirrors
    for url in mirrors:
        assert url.endswith("/mpc/mpc-1.4.1.tar.xz")
        assert "/gnu/gnu/" not in url


def test_gnu_mirrors_excludes_blocked_and_broken_hosts() -> None:
    """No generated mirror URL points at a host known to be blocked or TLS-broken.

    ftpmirror.gnu.org and ftp.gnu.org are unreachable from behind some corporate
    firewalls; mirror.rit.edu serves a certificate that does not match its own
    hostname. None of the three belong in the fallback list.
    """
    mirrors = _gnu_mirrors("https://ftpmirror.gnu.org/sed/sed-4.10.tar.gz")
    joined = " ".join(mirrors)
    assert "mirror.rit.edu" not in joined
    assert "ftp.gnu.org" not in joined
    assert "ftpmirror.gnu.org" not in joined


def test_gnu_mirrors_ignores_non_gnu_url() -> None:
    """A non-GNU primary URL yields no GNU mirror candidates."""
    assert _gnu_mirrors("https://example.com/pkg-1.0.tar.gz") == []


def test_gnupg_mirrors_switches_between_official_hosts() -> None:
    """GnuPG downloads can retry through the alternate official HTTPS hostname."""
    mirrors = _gnupg_mirrors("https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.5.22.tar.bz2")
    assert mirrors == [
        "https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.5.22.tar.bz2",
        "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.5.22.tar.bz2",
    ]


def test_gnupg_mirrors_normalizes_ftp_host_path() -> None:
    """ftp.gnupg.org uses /gcrypt/ rather than the web hosts' /ftp/gcrypt/."""
    mirrors = _gnupg_mirrors("https://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.5.22.tar.bz2")
    assert mirrors[0] == "https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.5.22.tar.bz2"


def test_gnupg_mirrors_ignores_non_gcrypt_url() -> None:
    """A non-GnuPG or non-gcrypt URL yields no GnuPG mirror candidates."""
    assert _gnupg_mirrors("https://example.com/gnupg-2.5.22.tar.bz2") == []
    assert _gnupg_mirrors("https://gnupg.org/download/gnupg-2.5.22.tar.bz2") == []


def test_savannah_mirrors_strips_releases_prefix() -> None:
    """download.savannah.nongnu.org URLs are rooted at '/releases/<path>'."""
    mirrors = _savannah_mirrors(
        "https://download.savannah.nongnu.org/releases/lzip/lzip-1.26.tar.gz"
    )
    assert mirrors
    for url in mirrors:
        assert url.endswith("/lzip/lzip-1.26.tar.gz")
        assert "/releases/" not in url


def test_savannah_mirrors_ignores_non_savannah_url() -> None:
    """A non-Savannah primary URL yields no Savannah mirror candidates."""
    assert _savannah_mirrors("https://example.com/pkg-1.0.tar.gz") == []
