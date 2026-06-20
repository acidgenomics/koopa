"""Generate man page module unit tests."""

from koopa.generate_man import (
    _bold,
    _italic,
    _roff_name,
    _section,
    _subsection,
    _tp,
    generate_man,
)


def test_roff_name_escapes_hyphens() -> None:
    """Test _roff_name escapes hyphens for roff."""
    assert _roff_name("deploy-to-aws") == r"deploy\-to\-aws"


def test_roff_name_no_hyphens() -> None:
    """Test _roff_name leaves non-hyphenated names alone."""
    assert _roff_name("install") == "install"


def test_bold() -> None:
    """Test _bold wraps text in roff bold markers."""
    assert _bold("koopa") == r"\fBkoopa\fR"


def test_italic() -> None:
    """Test _italic wraps text in roff italic markers."""
    assert _italic("app") == r"\fIapp\fR"


def test_section() -> None:
    """Test _section generates roff section header."""
    result = _section("NAME")
    assert '.SH "NAME"' in result


def test_subsection() -> None:
    """Test _subsection generates roff subsection header."""
    result = _subsection("Linux")
    assert '.SS "Linux"' in result


def test_tp() -> None:
    """Test _tp generates a tagged paragraph."""
    result = _tp("term", "description")
    assert ".TP" in result
    assert "term" in result
    assert "description" in result


def test_generate_man_contains_header() -> None:
    """Test generated man page contains TH header."""
    content = generate_man()
    assert ".TH" in content
    assert "KOOPA" in content


def test_generate_man_contains_name_section() -> None:
    """Test generated man page has NAME section."""
    content = generate_man()
    assert '.SH "NAME"' in content


def test_generate_man_contains_commands_section() -> None:
    """Test generated man page has COMMANDS section."""
    content = generate_man()
    assert '.SH "COMMANDS"' in content


def test_generate_man_contains_run_section() -> None:
    """Test generated man page has RUN SUBCOMMANDS section."""
    content = generate_man()
    assert '.SH "RUN SUBCOMMANDS"' in content


def test_generate_man_contains_develop_section() -> None:
    """Test generated man page has DEVELOP SUBCOMMANDS section."""
    content = generate_man()
    assert '.SH "DEVELOP SUBCOMMANDS"' in content


def test_generate_man_contains_system_section() -> None:
    """Test generated man page has SYSTEM SUBCOMMANDS section."""
    content = generate_man()
    assert '.SH "SYSTEM SUBCOMMANDS"' in content


def test_generate_man_contains_install_command() -> None:
    """Test generated man page documents install command."""
    content = generate_man()
    assert "install" in content.lower()


def test_generate_man_contains_run_command() -> None:
    """Test generated man page documents koopa run command."""
    content = generate_man()
    assert "run" in content
