"""Tests for koopa app sys linker-check."""

from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.cli_app import _PYTHON_HANDLERS
from koopa.linker import (
    Finding,
    _audit_macho_linux,
    _audit_macho_macos,
    classify_dependency,
    classify_install_name,
    classify_resolved_dependency,
    expand_at_path,
    linker_check,
    parse_ldd_output,
    parse_otool_dependencies,
    parse_otool_header,
    parse_otool_install_names,
    parse_otool_rpaths,
    parse_pc_koopa_paths,
)


def _link_app(opt_dir: Path, app_dir: Path, name: str, version: str) -> Path:
    """Create app/<name>/<version> and symlink opt/<name> to it. Returns the version dir."""
    version_dir = app_dir / name / version
    version_dir.mkdir(parents=True)
    (opt_dir / name).symlink_to(version_dir)
    return version_dir


# -- parse_otool_header -------------------------------------------------------


def test_parse_otool_header_thin() -> None:
    """A thin-binary header yields an empty arch string."""
    assert parse_otool_header("/path/to/rsync:") == ("/path/to/rsync", "")


def test_parse_otool_header_multi_arch() -> None:
    """A fat-binary header yields the architecture."""
    assert parse_otool_header("/path/to/lib.dylib (architecture arm64):") == (
        "/path/to/lib.dylib",
        "arm64",
    )


def test_parse_otool_header_error_line_is_not_a_header() -> None:
    """Otool's stdout error line for a non-object file is not a header."""
    assert parse_otool_header("/path/to/script.py: is not an object file") is None


def test_parse_otool_header_indented_line_is_not_a_header() -> None:
    """A tab-indented dependency line is never a header."""
    assert parse_otool_header("\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0):") is None


# -- parse_otool_dependencies -------------------------------------------------


def test_parse_otool_dependencies_multi_arch_block() -> None:
    """A real 3-arch block yields 3 separate keys, compatibility suffix stripped."""
    output = (
        "/path/to/lib.dylib (architecture x86_64):\n"
        "\t@rpath/lib.dylib (compatibility version 0.0.0, current version 0.0.0)\n"
        "\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)\n"
        "/path/to/lib.dylib (architecture x86_64h):\n"
        "\t@rpath/lib.dylib (compatibility version 0.0.0, current version 0.0.0)\n"
        "/path/to/lib.dylib (architecture arm64):\n"
        "\t@rpath/lib.dylib (compatibility version 0.0.0, current version 0.0.0)\n"
    )
    deps = parse_otool_dependencies(output)
    assert set(deps) == {
        ("/path/to/lib.dylib", "x86_64"),
        ("/path/to/lib.dylib", "x86_64h"),
        ("/path/to/lib.dylib", "arm64"),
    }
    assert deps[("/path/to/lib.dylib", "x86_64")] == [
        "@rpath/lib.dylib",
        "/usr/lib/libSystem.B.dylib",
    ]


def test_parse_otool_dependencies_error_line_does_not_leak() -> None:
    """An interleaved 'is not an object file' line adds no entry to the prior key."""
    output = (
        "/path/to/rsync:\n"
        "\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)\n"
        "/path/to/script.py: is not an object file\n"
    )
    deps = parse_otool_dependencies(output)
    assert deps[("/path/to/rsync", "")] == ["/usr/lib/libSystem.B.dylib"]
    assert len(deps) == 1


# -- install-name suppression -------------------------------------------------


def test_install_name_matches_first_dependency_entry() -> None:
    """Otool -D's output for a dylib exactly matches otool -L's first entry."""
    dep_output = (
        "/path/to/libzstd.dylib:\n"
        "\t@rpath/libzstd.1.dylib (compatibility version 1.0.0, current version 1.5.7)\n"
        "\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)\n"
    )
    name_output = "/path/to/libzstd.dylib:\n@rpath/libzstd.1.dylib\n"
    deps = parse_otool_dependencies(dep_output)
    names = parse_otool_install_names(name_output)
    key = ("/path/to/libzstd.dylib", "")
    assert names[key] == "@rpath/libzstd.1.dylib"
    assert deps[key][0] == names[key]


def test_repeated_install_name_string_later_in_list_is_not_dropped() -> None:
    """Only index 0 is ever suppressed; an unrelated later repeat stays."""
    dep_output = (
        "/path/to/lib.dylib:\n"
        "\t@rpath/lib.dylib (compatibility version 1.0.0, current version 1.0.0)\n"
        "\t@rpath/lib.dylib (compatibility version 1.0.0, current version 1.0.0)\n"
    )
    deps = parse_otool_dependencies(dep_output)
    key = ("/path/to/lib.dylib", "")
    own_name = "@rpath/lib.dylib"
    entries = deps[key][1:] if deps[key] and deps[key][0] == own_name else deps[key]
    assert entries == ["@rpath/lib.dylib"]


# -- parse_otool_rpaths --------------------------------------------------------


def test_parse_otool_rpaths_keeps_at_relative_entries() -> None:
    """@loader_path-relative rpaths are kept (build._extract_rpath_macos drops them)."""
    output = (
        "/path/to/nu_plugin_query:\n"
        "Load command 10\n"
        "      cmd LC_RPATH\n"
        "  cmdsize 40\n"
        "     path @loader_path/../lib (offset 12)\n"
    )
    rpaths = parse_otool_rpaths(output)
    assert rpaths[("/path/to/nu_plugin_query", "")] == ["@loader_path/../lib"]


def test_parse_otool_rpaths_no_rpath_commands_yields_empty_list_not_missing_key() -> None:
    """A binary with zero LC_RPATH commands gets an explicit empty list."""
    output = "/path/to/rsync:\nLoad command 0\n      cmd LC_SEGMENT\n"
    rpaths = parse_otool_rpaths(output)
    assert rpaths[("/path/to/rsync", "")] == []


# -- expand_at_path -------------------------------------------------------


@pytest.mark.parametrize(
    ("entry", "expected"),
    [
        ("@loader_path/../lib", "/prefix/lib"),
        ("@executable_path/../lib", "/prefix/lib"),
        ("@rpath/lib.dylib", "@rpath/lib.dylib"),
        ("/absolute/lib.dylib", "/absolute/lib.dylib"),
    ],
)
def test_expand_at_path(entry: str, expected: str) -> None:
    """@loader_path/@executable_path expand; @rpath and absolute pass through."""
    assert expand_at_path(entry, "/prefix/bin") == expected


# -- classify_dependency -------------------------------------------------------


def test_classify_dependency_usr_lib_is_exempt_even_when_missing_on_disk() -> None:
    """/usr/lib is shared-cache-resident and must not be flagged as dangling."""
    verdict = classify_dependency(
        "/usr/lib/libcurl.4.dylib",
        binary_dir="/prefix/bin",
        rpaths=[],
        app_root="/koopa/app",
        current={},
    )
    assert verdict is None


def test_classify_dependency_rpath_unresolvable() -> None:
    """An @rpath entry with no matching LC_RPATH is unresolvable."""
    verdict = classify_dependency(
        "@rpath/libcurl.4.dylib",
        binary_dir="/koopa/app/nushell/1.0/libexec/bin",
        rpaths=["@loader_path/../lib"],
        app_root="/koopa/app",
        current={},
    )
    assert verdict == (
        "rpath",
        "none of 1 LC_RPATH entries contain it; dyld will fall back to a system library",
    )


def test_classify_dependency_rpath_no_entries() -> None:
    """An @rpath entry with zero LC_RPATH entries gets a distinct reason."""
    verdict = classify_dependency(
        "@rpath/lib.dylib",
        binary_dir="/koopa/app/foo/1.0/bin",
        rpaths=[],
        app_root="/koopa/app",
        current={},
    )
    assert verdict == ("rpath", "no LC_RPATH entries")


def test_classify_dependency_relative() -> None:
    """A relative dependency path resolves against the process cwd."""
    verdict = classify_dependency(
        "uv/cpython-3.14.7-macos-aarch64-none/lib/libpython3.14.dylib",
        binary_dir="/koopa/app/python3.14/3.14.7/lib",
        rpaths=[],
        app_root="/koopa/app",
        current={},
    )
    assert verdict == ("relative", "dependency path is relative to the process cwd")


def test_classify_dependency_foreign_prefix() -> None:
    """A Homebrew path is outside the koopa app prefix."""
    verdict = classify_dependency(
        "/opt/homebrew/lib/libfoo.dylib",
        binary_dir="/koopa/app/foo/1.0/bin",
        rpaths=[],
        app_root="/koopa/app",
        current={},
    )
    assert verdict == (
        "foreign",
        "'/opt/homebrew/lib/libfoo.dylib' is outside the koopa app prefix",
    )


def test_classify_dependency_dangling(tmp_path: Path) -> None:
    """An absolute koopa-prefix dependency that doesn't exist on disk is dangling."""
    app_root = str(tmp_path / "app")
    verdict = classify_dependency(
        f"{app_root}/zstd/1.5.6/lib/libzstd.dylib",
        binary_dir=f"{app_root}/rsync/3.5.1/bin",
        rpaths=[],
        app_root=app_root,
        current={"zstd": "1.5.6"},
    )
    assert verdict == ("dangling", f"'{app_root}/zstd/1.5.6/lib/libzstd.dylib' does not exist")


def test_classify_dependency_stale_version(tmp_path: Path) -> None:
    """A dependency linked at a version other than the current opt/ target is stale."""
    app_root = tmp_path / "app"
    dep_dir = app_root / "zstd" / "1.5.6"
    dep_dir.mkdir(parents=True)
    (dep_dir / "lib").mkdir()
    lib_file = dep_dir / "lib" / "libzstd.dylib"
    lib_file.write_bytes(b"")
    verdict = classify_dependency(
        str(lib_file),
        binary_dir=str(app_root / "rsync" / "3.5.1" / "bin"),
        rpaths=[],
        app_root=str(app_root),
        current={"zstd": "1.5.7"},
    )
    assert verdict == ("stale", "links zstd 1.5.6, but opt/zstd is 1.5.7")


def test_classify_dependency_stale_no_opt_symlink(tmp_path: Path) -> None:
    """A dependency for an app with no opt/ symlink at all is still stale."""
    app_root = tmp_path / "app"
    dep_dir = app_root / "zstd" / "1.5.6" / "lib"
    dep_dir.mkdir(parents=True)
    lib_file = dep_dir / "libzstd.dylib"
    lib_file.write_bytes(b"")
    verdict = classify_dependency(
        str(lib_file),
        binary_dir=str(app_root / "rsync" / "3.5.1" / "bin"),
        rpaths=[],
        app_root=str(app_root),
        current={},
    )
    assert verdict == ("stale", "links zstd, which has no opt/ symlink")


def test_classify_dependency_clean_resolves(tmp_path: Path) -> None:
    """A dependency at the current version that exists on disk is clean."""
    app_root = tmp_path / "app"
    dep_dir = app_root / "zstd" / "1.5.7" / "lib"
    dep_dir.mkdir(parents=True)
    lib_file = dep_dir / "libzstd.dylib"
    lib_file.write_bytes(b"")
    verdict = classify_dependency(
        str(lib_file),
        binary_dir=str(app_root / "rsync" / "3.5.1" / "bin"),
        rpaths=[],
        app_root=str(app_root),
        current={"zstd": "1.5.7"},
    )
    assert verdict is None


# -- classify_install_name -----------------------------------------------------


def test_classify_install_name_relative() -> None:
    """A uv-built Python dylib's relative install name is flagged."""
    verdict = classify_install_name("uv/cpython-3.14.7-macos-aarch64-none/lib/libpython3.14.dylib")
    assert verdict == (
        "relative",
        "dylib's own install name is relative: "
        "'uv/cpython-3.14.7-macos-aarch64-none/lib/libpython3.14.dylib'",
    )


@pytest.mark.parametrize("install_name", ["@rpath/lib.dylib", "/koopa/app/foo/1.0/lib/lib.dylib"])
def test_classify_install_name_absolute_or_at_relative_is_clean(install_name: str) -> None:
    """An @-relative or absolute install name is not flagged."""
    assert classify_install_name(install_name) is None


# -- cross-architecture dedup --------------------------------------------------


def test_audit_macho_macos_dedupes_across_architectures() -> None:
    """Three identical per-arch findings collapse to one Finding."""
    dep_output = "".join(
        f"/koopa/app/foo/1.0/lib/lib.dylib (architecture {arch}):\n"
        "\t@rpath/lib.dylib (compatibility version 0.0.0, current version 0.0.0)\n"
        "\t@rpath/missing.dylib (compatibility version 0.0.0, current version 0.0.0)\n"
        for arch in ("x86_64", "x86_64h", "arm64")
    )
    name_output = "".join(
        f"/koopa/app/foo/1.0/lib/lib.dylib (architecture {arch}):\n@rpath/lib.dylib\n"
        for arch in ("x86_64", "x86_64h", "arm64")
    )
    archs = ("x86_64", "x86_64h", "arm64")
    rpath_output = "".join(
        f"/koopa/app/foo/1.0/lib/lib.dylib (architecture {arch}):\n" for arch in archs
    )
    with patch(
        "koopa.linker._run_otool",
        side_effect=lambda flag, _files, **_kwargs: {
            "-L": dep_output,
            "-D": name_output,
            "-l": rpath_output,
        }[flag],
    ):
        findings = _audit_macho_macos(
            ["/koopa/app/foo/1.0/lib/lib.dylib"],
            {"/koopa/app/foo/1.0/lib/lib.dylib": "foo"},
            "/koopa/app",
            {"foo": "1.0"},
        )
    assert findings == [
        Finding(
            "foo",
            "/koopa/app/foo/1.0/lib/lib.dylib",
            "rpath",
            "@rpath/missing.dylib",
            "no LC_RPATH entries",
        )
    ]


# -- parse_pc_koopa_paths -------------------------------------------------------


def test_parse_pc_koopa_paths_extracts_and_dedupes() -> None:
    """-L/-I koopa paths are extracted; ${libdir} and trailing punctuation are handled."""
    text = (
        "libdir=${prefix}/lib\n"
        "Cflags: -I/koopa/app/foo/1.0/include\n"
        "Libs: -L/koopa/app/foo/1.0/lib -L/koopa/app/foo/1.0/lib\n"
        'extra="/koopa/app/foo/1.0/lib",\n'
    )
    paths = parse_pc_koopa_paths(text, "/koopa/app")
    assert paths == ["/koopa/app/foo/1.0/include", "/koopa/app/foo/1.0/lib"]


def test_parse_pc_koopa_paths_ignores_unexpanded_libdir() -> None:
    """An unexpanded ${libdir} reference never starts with the literal app_root."""
    text = "Libs: -L${libdir}\n"
    assert parse_pc_koopa_paths(text, "/koopa/app") == []


# -- parse_ldd_output (Linux) --------------------------------------------------
#
# Line shapes verified against glibc's own trace printer (elf/rtld.c's
# _dl_printf calls), not from memory: "%s => not found", "%s => %s (0xADDR)",
# a bare "%s (0xADDR)" with no "=>" for the vDSO pseudo-entry, and
# "statically linked" for a static binary. Unverified end to end against a
# real Linux host.


def test_parse_ldd_output_resolved_dependency() -> None:
    """A normal resolved dependency maps the raw soname to its real path."""
    output = "\tlibc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1234567000)\n"
    assert parse_ldd_output(output) == {"libc.so.6": "/lib/x86_64-linux-gnu/libc.so.6"}


def test_parse_ldd_output_missing_dependency() -> None:
    """A "not found" dependency maps to None."""
    output = "\tlibfoo.so.1 => not found\n"
    assert parse_ldd_output(output) == {"libfoo.so.1": None}


def test_parse_ldd_output_vdso_pseudo_entry_contributes_nothing() -> None:
    """The vDSO's bare '%s (0xADDR)' line has no backing file and is skipped."""
    output = "\tlinux-vdso.so.1 (0x00007ffee4321000)\n"
    assert parse_ldd_output(output) == {}


def test_parse_ldd_output_statically_linked_contributes_nothing() -> None:
    """A statically-linked binary has no dependencies to classify."""
    assert parse_ldd_output("\tstatically linked\n") == {}


def test_parse_ldd_output_self_identical_absolute_path_is_classified(tmp_path: Path) -> None:
    """A DT_NEEDED entry that is itself an absolute path resolving to itself.

    Uses the same bare '%s (0xADDR)' shape as the vDSO, distinguished only
    by whether a real file exists at that path.
    """
    lib_file = tmp_path / "libfoo.so"
    lib_file.write_bytes(b"")
    output = f"\t{lib_file} (0x00007f1234567000)\n"
    assert parse_ldd_output(output) == {str(lib_file): str(lib_file)}


def test_parse_ldd_output_combined_real_shaped_block() -> None:
    """A realistic multi-line block parses every shape independently."""
    output = (
        "\tlinux-vdso.so.1 (0x00007ffee4321000)\n"
        "\tlibz.so.1 => /koopa/app/zlib/1.3.2/lib/libz.so.1 (0x00007f1111111000)\n"
        "\tlibmissing.so.2 => not found\n"
        "\tlibc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f2222222000)\n"
    )
    deps = parse_ldd_output(output)
    assert deps == {
        "libz.so.1": "/koopa/app/zlib/1.3.2/lib/libz.so.1",
        "libmissing.so.2": None,
        "libc.so.6": "/lib/x86_64-linux-gnu/libc.so.6",
    }


# -- classify_resolved_dependency (Linux) --------------------------------------


def test_classify_resolved_dependency_missing_bare_soname() -> None:
    """A missing bare soname is an unresolvable dependency, not dangling."""
    verdict = classify_resolved_dependency("libfoo.so.1", None, app_root="/koopa/app", current={})
    assert verdict == (
        "rpath",
        "ldd could not resolve 'libfoo.so.1' via RPATH/RUNPATH or the system default paths",
    )


def test_classify_resolved_dependency_missing_absolute_path() -> None:
    """A missing DT_NEEDED entry that was itself an absolute path is dangling."""
    verdict = classify_resolved_dependency(
        "/koopa/app/foo/1.0/lib/libfoo.so", None, app_root="/koopa/app", current={}
    )
    assert verdict == ("dangling", "'/koopa/app/foo/1.0/lib/libfoo.so' does not exist")


@pytest.mark.parametrize("resolved", ["/usr/lib/libc.so.6", "/lib64/libc.so.6"])
def test_classify_resolved_dependency_system_paths_are_exempt(resolved: str) -> None:
    """Standard Linux system library directories are not koopa's problem."""
    verdict = classify_resolved_dependency("libc.so.6", resolved, app_root="/koopa/app", current={})
    assert verdict is None


def test_classify_resolved_dependency_stale_version(tmp_path: Path) -> None:
    """A resolved path under app_root at a non-current version is stale."""
    app_root = tmp_path / "app"
    dep_dir = app_root / "zlib" / "1.3.1" / "lib"
    dep_dir.mkdir(parents=True)
    lib_file = dep_dir / "libz.so.1"
    lib_file.write_bytes(b"")
    verdict = classify_resolved_dependency(
        "libz.so.1", str(lib_file), app_root=str(app_root), current={"zlib": "1.3.2"}
    )
    assert verdict == ("stale", "links zlib 1.3.1, but opt/zlib is 1.3.2")


def test_classify_resolved_dependency_foreign_prefix() -> None:
    """A resolved path outside both app_root and the system dirs is foreign."""
    verdict = classify_resolved_dependency(
        "libssl.so.3", "/opt/conda/lib/libssl.so.3", app_root="/koopa/app", current={}
    )
    assert verdict == ("foreign", "'/opt/conda/lib/libssl.so.3' is outside the koopa app prefix")


def test_classify_resolved_dependency_clean_resolves(tmp_path: Path) -> None:
    """A resolved path at the current version is clean."""
    app_root = tmp_path / "app"
    dep_dir = app_root / "zlib" / "1.3.2" / "lib"
    dep_dir.mkdir(parents=True)
    lib_file = dep_dir / "libz.so.1"
    lib_file.write_bytes(b"")
    verdict = classify_resolved_dependency(
        "libz.so.1", str(lib_file), app_root=str(app_root), current={"zlib": "1.3.2"}
    )
    assert verdict is None


# -- _audit_macho_linux end-to-end ----------------------------------------------


def test_audit_macho_linux_skips_non_elf_files(tmp_path: Path) -> None:
    """A candidate file with no ELF magic bytes is never passed to ldd."""
    script = tmp_path / "wrapper.sh"
    script.write_text("#!/bin/sh\necho hi\n")
    with patch("koopa.linker._run_ldd") as mock_run_ldd:
        findings = _audit_macho_linux([str(script)], {str(script): "myapp"}, "/koopa/app", {})
    mock_run_ldd.assert_not_called()
    assert findings == []


def test_audit_macho_linux_reports_unresolvable_dependency(tmp_path: Path) -> None:
    """An ELF file with a missing bare-soname dependency produces one finding."""
    binary = tmp_path / "rsync"
    binary.write_bytes(b"\x7fELF" + b"\x00" * 60)
    ldd_output = "\tlibmissing.so.2 => not found\n"
    with patch("koopa.linker._run_ldd", return_value=ldd_output):
        findings = _audit_macho_linux([str(binary)], {str(binary): "rsync"}, "/koopa/app", {})
    assert findings == [
        Finding(
            "rsync",
            str(binary),
            "rpath",
            "libmissing.so.2",
            "ldd could not resolve 'libmissing.so.2' via RPATH/RUNPATH or the system default paths",
        )
    ]


# -- linker_check end-to-end ----------------------------------------------------


def test_linker_check_clean_returns_true(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A tree with no findings returns True and prints only a header."""
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    app_dir = tmp_path / "app"
    app_dir.mkdir()
    _link_app(opt_dir, app_dir, "myapp", "1.0")
    with (
        patch("koopa.linker._current_app_prefixes", return_value={}),
        patch("koopa.linker._macho_candidates", return_value=([], {})),
        patch("koopa.linker._pkgconfig_candidates", return_value=[]),
    ):
        assert linker_check() is True
    captured = capsys.readouterr()
    assert captured.out == ""


def test_linker_check_findings_on_stdout_header_on_stderr(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Finding lines land on stdout; header/summary narration lands on stderr."""
    prefixes = {"myapp": "/koopa/app/myapp/1.0"}
    finding = Finding(
        "myapp", "/koopa/app/myapp/1.0/bin/myapp", "foreign", "/opt/homebrew/lib/x.dylib", "boom"
    )
    with (
        patch("koopa.linker._current_app_prefixes", return_value=prefixes),
        patch("koopa.linker._macho_candidates", return_value=(["f"], {"f": "myapp"})),
        patch("koopa.linker._pkgconfig_candidates", return_value=[]),
        patch("koopa.linker._audit_macho", return_value=[finding]),
    ):
        assert linker_check() is False
    captured = capsys.readouterr()
    assert "myapp: bin/myapp: boom" in captured.out
    assert "boom" not in captured.err
    assert "Checking Mach-O linkage" in captured.err
    assert "1 finding in 1 of 1 apps" in captured.err


def test_linker_check_filtered_apps_keep_full_current_version_map() -> None:
    """Filtering to one app must not blind classify_dependency to its deps' versions.

    Regression test: filtering ``prefixes`` down to the requested apps before
    building ``current`` made every dependency outside that filter look like
    it "has no opt/ symlink" (found live: ``linker-check rsync zstd`` falsely
    flagged lz4/xxhash/openssl4/zlib/xz as stale). ``current`` must always be
    built from every installed app, regardless of the ``apps`` filter.
    """
    all_prefixes = {"myapp": "/koopa/app/myapp/1.0", "dep": "/koopa/app/dep/2.0"}
    with (
        patch("koopa.linker._current_app_prefixes", return_value=all_prefixes),
        patch("koopa.linker._macho_candidates", return_value=([], {})) as mock_candidates,
        patch("koopa.linker._pkgconfig_candidates", return_value=[]),
        patch("koopa.linker._audit_macho", return_value=[]) as mock_audit,
    ):
        linker_check(["myapp"])
    # The file scan is scoped to the filtered app...
    scanned_prefixes = mock_candidates.call_args.args[0]
    assert set(scanned_prefixes) == {"myapp"}
    # ...but the version-reference map passed to the classifier is not.
    passed_current = mock_audit.call_args.args[3]
    assert passed_current == {"myapp": "1.0", "dep": "2.0"}


def test_linker_check_unknown_app_raises() -> None:
    """Filtering to an app that is not installed raises ValueError."""
    with (
        patch("koopa.linker._current_app_prefixes", return_value={"myapp": "/koopa/app/myapp/1.0"}),
        pytest.raises(ValueError, match="not-installed"),
    ):
        linker_check(["not-installed"])


# -- handler --------------------------------------------------------------------


def test_sys_linker_check_registered() -> None:
    """sys-linker-check is registered in _PYTHON_HANDLERS."""
    assert "sys-linker-check" in _PYTHON_HANDLERS
    assert callable(_PYTHON_HANDLERS["sys-linker-check"])


def test_sys_linker_check_help(capsys: pytest.CaptureFixture[str]) -> None:
    """--help exits cleanly and mentions linkage."""
    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS["sys-linker-check"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "linkage" in captured.out.lower()


def test_sys_linker_check_exits_1_on_findings() -> None:
    """The handler exits 1 when linker_check() reports findings."""
    with (
        patch("koopa.system.is_macos", return_value=True),
        patch("koopa.linker.linker_check", return_value=False),
        pytest.raises(SystemExit) as exc_info,
    ):
        _PYTHON_HANDLERS["sys-linker-check"]([])
    assert exc_info.value.code == 1


def test_sys_linker_check_raises_on_non_macos() -> None:
    """The handler raises on a non-macOS platform."""
    with (
        patch("koopa.system.is_macos", return_value=False),
        pytest.raises(RuntimeError, match="macOS-only"),
    ):
        _PYTHON_HANDLERS["sys-linker-check"]([])
