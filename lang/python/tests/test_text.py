"""Text module unit tests."""

from pathlib import Path

from koopa.text import (
    autopad_zeros,
    camel_case,
    detab,
    entab,
    eol_lf,
    find_and_replace_in_file,
    grep,
    grep_string,
    head,
    kebab_case,
    nchar,
    nlines,
    pascal_case,
    snake_case,
    sort_lines,
    tail,
    to_string,
)


def test_camel_case_underscore() -> None:
    """Test camelCase conversion from underscore."""
    assert camel_case("hello_world") == "helloWorld"


def test_camel_case_spaces() -> None:
    """Test camelCase conversion from spaces."""
    assert camel_case("hello world") == "helloWorld"


def test_camel_case_kebab() -> None:
    """Test camelCase conversion from kebab-case."""
    assert camel_case("foo-bar-baz") == "fooBarBaz"


def test_camel_case_empty() -> None:
    """Test camelCase conversion with empty string."""
    assert camel_case("") == ""


def test_pascal_case_underscore() -> None:
    """Test PascalCase conversion from underscore."""
    assert pascal_case("hello_world") == "HelloWorld"


def test_pascal_case_dots() -> None:
    """Test PascalCase conversion from dots."""
    assert pascal_case("foo.bar.baz") == "FooBarBaz"


def test_kebab_case_from_camel() -> None:
    """Test kebab-case conversion from camelCase."""
    assert kebab_case("helloWorld") == "hello-world"


def test_kebab_case_from_snake() -> None:
    """Test kebab-case conversion from snake_case."""
    assert kebab_case("hello_world") == "hello-world"


def test_kebab_case_from_pascal() -> None:
    """Test kebab-case conversion from PascalCase."""
    assert kebab_case("HelloWorld") == "hello-world"


def test_snake_case_from_camel() -> None:
    """Test snake_case conversion from camelCase."""
    assert snake_case("helloWorld") == "hello_world"


def test_snake_case_from_kebab() -> None:
    """Test snake_case conversion from kebab-case."""
    assert snake_case("hello-world") == "hello_world"


def test_snake_case_from_pascal() -> None:
    """Test snake_case conversion from PascalCase."""
    assert snake_case("HelloWorld") == "hello_world"


def test_snake_case_spaces() -> None:
    """Test snake_case conversion from spaces."""
    assert snake_case("Hello World") == "hello_world"


def test_grep_string_fixed() -> None:
    """Test grep_string with fixed pattern."""
    text = "alpha\nbeta\ngamma\nalpha-beta"
    assert grep_string("beta", text, fixed=True) == ["beta", "alpha-beta"]


def test_grep_string_regex() -> None:
    """Test grep_string with regex pattern."""
    text = "foo123\nbar456\nbaz"
    assert grep_string(r"\d+", text) == ["foo123", "bar456"]


def test_grep_string_no_match() -> None:
    """Test grep_string with no matching lines."""
    assert grep_string("xyz", "abc\ndef", fixed=True) == []


def test_nchar() -> None:
    """Test nchar returns string length."""
    assert nchar("hello") == 5


def test_nchar_empty() -> None:
    """Test nchar with empty string."""
    assert nchar("") == 0


def test_to_string_default_sep() -> None:
    """Test to_string with default separator."""
    assert to_string(["a", "b", "c"]) == "a b c"


def test_to_string_custom_sep() -> None:
    """Test to_string with custom separator."""
    assert to_string(["a", "b"], sep=",") == "a,b"


def test_to_string_integers() -> None:
    """Test to_string with integer items."""
    assert to_string([1, 2, 3]) == "1 2 3"


def test_find_and_replace_in_file_fixed(tmp_path: Path) -> None:
    """Test find and replace with fixed string."""
    p = tmp_path / "test.txt"
    p.write_text("hello world\nhello again\n")
    find_and_replace_in_file(str(p), "hello", "hi", fixed=True)
    assert p.read_text() == "hi world\nhi again\n"


def test_find_and_replace_in_file_regex(tmp_path: Path) -> None:
    """Test find and replace with regex pattern."""
    p = tmp_path / "test.txt"
    p.write_text("foo123bar\n")
    find_and_replace_in_file(str(p), r"\d+", "NUM")
    assert p.read_text() == "fooNUMbar\n"


def test_detab(tmp_path: Path) -> None:
    """Test tab to space conversion."""
    p = tmp_path / "test.txt"
    p.write_text("\thello\n\t\tworld\n")
    detab(str(p), tab_size=4)
    assert p.read_text() == "    hello\n        world\n"


def test_entab(tmp_path: Path) -> None:
    """Test space to tab conversion."""
    p = tmp_path / "test.txt"
    p.write_text("    hello\n        world\n")
    entab(str(p), tab_size=4)
    assert p.read_text() == "\thello\n\t\tworld\n"


def test_eol_lf(tmp_path: Path) -> None:
    """Test CRLF to LF conversion."""
    p = tmp_path / "test.txt"
    p.write_bytes(b"line1\r\nline2\r\n")
    eol_lf(str(p))
    assert p.read_bytes() == b"line1\nline2\n"


def test_sort_lines(tmp_path: Path) -> None:
    """Test line sorting."""
    p = tmp_path / "test.txt"
    p.write_text("cherry\napple\nbanana\n")
    sort_lines(str(p))
    assert p.read_text() == "apple\nbanana\ncherry\n"


def test_sort_lines_unique(tmp_path: Path) -> None:
    """Test line sorting with unique deduplication."""
    p = tmp_path / "test.txt"
    p.write_text("b\na\nb\nc\na\n")
    sort_lines(str(p), unique=True)
    assert p.read_text() == "a\nb\nc\n"


def test_head(tmp_path: Path) -> None:
    """Test head returns first n lines."""
    p = tmp_path / "test.txt"
    p.write_text("line1\nline2\nline3\nline4\nline5\n")
    assert head(str(p), n=3) == ["line1", "line2", "line3"]


def test_tail(tmp_path: Path) -> None:
    """Test tail returns last n lines."""
    p = tmp_path / "test.txt"
    p.write_text("line1\nline2\nline3\nline4\nline5")
    assert tail(str(p), n=2) == ["line4", "line5"]


def test_grep_file_fixed(tmp_path: Path) -> None:
    """Test grep in file with fixed pattern."""
    p = tmp_path / "test.txt"
    p.write_text("alpha\nbeta\ngamma\n")
    assert grep("beta", str(p), fixed=True) == ["beta"]


def test_grep_file_regex(tmp_path: Path) -> None:
    """Test grep in file with regex pattern."""
    p = tmp_path / "test.txt"
    p.write_text("foo123\nbar\nbaz456\n")
    assert grep(r"\d+", str(p)) == ["foo123", "baz456"]


def test_nlines(tmp_path: Path) -> None:
    """Test nlines counts lines correctly."""
    p = tmp_path / "test.txt"
    p.write_text("a\nb\nc\n")
    assert nlines(str(p)) == 3


def test_autopad_zeros(tmp_path: Path) -> None:
    """Test autopad renames files with zero padding."""
    for i in range(1, 13):
        (tmp_path / f"{i}.txt").write_text("")
    renames = autopad_zeros(str(tmp_path))
    assert len(renames) > 0
    assert (tmp_path / "01.txt").exists()
    assert (tmp_path / "12.txt").exists()


def test_autopad_zeros_dry_run(tmp_path: Path) -> None:
    """Test autopad dry run does not rename files."""
    for i in range(1, 13):
        (tmp_path / f"{i}.txt").write_text("")
    renames = autopad_zeros(str(tmp_path), dry_run=True)
    assert len(renames) > 0
    assert (tmp_path / "1.txt").exists()
    assert not (tmp_path / "01.txt").exists()
