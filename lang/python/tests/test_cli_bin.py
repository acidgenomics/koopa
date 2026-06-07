"""CLI bin dispatch module unit tests."""

import subprocess
from unittest.mock import patch

import pytest
from koopa.cli_bin import _HANDLERS
from koopa.dns import nameserver_provider


def test_handlers_not_empty() -> None:
    """Test that _HANDLERS has entries."""
    assert len(_HANDLERS) > 0


def test_handlers_all_callable() -> None:
    """Test that all handler values are callable."""
    for name, handler in _HANDLERS.items():
        assert callable(handler), f"Handler for '{name}' is not callable"


def test_handlers_expected_commands() -> None:
    """Test that key utility commands are registered."""
    expected = [
        "rename-snake-case",
        "rename-kebab-case",
        "clone",
        "download",
        "extract",
        "find-and-replace",
        "sort-lines",
        "ip-address",
    ]
    for cmd in expected:
        assert cmd in _HANDLERS, f"Expected command '{cmd}' not in _HANDLERS"


def test_jekyll_serve_not_in_handlers() -> None:
    """Test that jekyll-serve is not in _HANDLERS (use koopa app jekyll serve)."""
    assert "jekyll-serve" not in _HANDLERS


def test_handler_rename_snake_case_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test rename-snake-case --help exits cleanly."""
    with pytest.raises(SystemExit) as exc_info:
        _HANDLERS["rename-snake-case"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "snake_case" in captured.out.lower() or "snake" in captured.out.lower()


def test_handler_download_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test download --help exits cleanly."""
    with pytest.raises(SystemExit) as exc_info:
        _HANDLERS["download"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "url" in captured.out.lower()


# -- dns command ---------------------------------------------------------------


def test_dns_in_handlers() -> None:
    """Test that dns is registered in _HANDLERS."""
    assert "dns" in _HANDLERS
    assert callable(_HANDLERS["dns"])


def test_handler_dns_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test dns --help exits cleanly and mentions route53."""
    with pytest.raises(SystemExit) as exc_info:
        _HANDLERS["dns"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "route53" in captured.out.lower()


def test_nameserver_provider_route53() -> None:
    """Test that awsdns nameservers are identified as Route 53."""
    assert nameserver_provider(["ns-20.awsdns-02.com."]) == "Route 53"
    assert nameserver_provider(["ns-1489.awsdns-58.org.", "ns-20.awsdns-02.com."]) == "Route 53"


def test_nameserver_provider_hover() -> None:
    """Test that hover.com nameservers are identified as Hover."""
    assert nameserver_provider(["ns1.hover.com.", "ns2.hover.com."]) == "Hover"


def test_nameserver_provider_other() -> None:
    """Test that unrecognised nameservers are labelled Other."""
    assert nameserver_provider(["ns1.example.net."]) == "Other"
    assert nameserver_provider([]) == "Other"


def test_handler_dns_output(capsys: pytest.CaptureFixture[str]) -> None:
    """Test dns command output format with mocked dig."""
    dig_responses = {
        ("acidgenomics.com", "NS"): "ns-20.awsdns-02.com.\n",
        ("acidgenomics.com", "A"): "1.2.3.4\n",
        ("acidgenomics.com", "AAAA"): "",
        ("acidgenomics.com", "MX"): "1 aspmx.l.google.com.\n",
        ("acidgenomics.com", "TXT"): '"v=spf1 include:_spf.google.com ~all"\n',
        ("_dmarc.acidgenomics.com", "TXT"): '"v=DMARC1; p=quarantine"\n',
    }

    def fake_run(cmd: list[str], **_: object) -> subprocess.CompletedProcess:
        name = cmd[2]
        rtype = cmd[3]
        stdout = dig_responses.get((name, rtype), "")
        return subprocess.CompletedProcess(cmd, 0, stdout=stdout, stderr="")

    with patch("koopa.dns.subprocess.run", side_effect=fake_run):
        _HANDLERS["dns"](["acidgenomics.com"])

    captured = capsys.readouterr()
    assert "acidgenomics.com" in captured.out
    assert "Route 53" in captured.out
    assert "NS:" in captured.out
    assert "MX:" in captured.out
    assert "_dmarc TXT:" in captured.out
