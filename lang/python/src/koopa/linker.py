"""Audit installed apps for Mach-O linkage problems.

``koopa app sys linker-info`` (see ``cli_app.py``) dumps raw ``otool -L``
output for files the caller names. This module is its audit sibling: it
enumerates every installed app itself and reports a verdict.

The otool-calling code (macOS) and the ldd-calling code (Linux) are each
isolated behind :func:`_audit_macho`, mirroring the ``is_macos()``/else
split already used by ``build._extract_rpath()``.

Linux does *not* reuse :func:`classify_dependency`. An early design note in
this docstring claimed it would; that was wrong, caught before writing the
Linux backend rather than after. A Mach-O ``LC_LOAD_DYLIB`` entry is always
path-shaped (``@rpath/...``, ``@loader_path/...``, or an absolute path). An
ELF ``DT_NEEDED`` entry is usually a *bare soname* (``libc.so.6``, no slash
at all), resolved by the dynamic linker searching RPATH/RUNPATH/ld.so.cache/
defaults. Feeding a bare soname through :func:`classify_dependency` would
hit its ``if not dep.startswith("/")`` branch and misreport nearly every
normal Linux dependency as "relative." The genuinely reusable piece is
:func:`_classify_koopa_path`, the inner absolute-path classifier (dangling/
foreign/stale-version), which was already split out from the macOS
dispatcher because it has no Mach-O-specific logic in it. The Linux backend
calls ``ldd`` (which already implements the full, correct RPATH/RUNPATH/
ld.so.cache resolution search) to get each dependency's resolved path, then
feeds that resolved path into :func:`_classify_koopa_path`. No ``readelf``
or ``objdump`` call is needed.

This intentionally does not call ``build._extract_rpath_macos()``: that
function drops ``@``-relative RPATH entries and swallows all subprocess
errors to ``[]``, which is correct for its one caller (a build-time gate in
``activate_app()``) and wrong here, where the raw entries (including the
zero-entries case) are exactly what a linkage audit needs.

Verification note: the Linux backend was written from verified glibc/
binutils source (``elf/rtld.c``'s ``_dl_printf`` calls for the exact ``ldd``
trace-output format), not from memory, because this repo has no ELF
binaries to test against. It has not been run against a real Linux host.

Four of the six checks below (dangling absolute dependency, foreign prefix
leak, stale dependency version, dangling pkg-config path) have zero real
instances on a clean koopa install. They exist to catch future regressions
in installer wiring; their only coverage is the unit tests in
``test_cli_app_sys.py``. A clean run of those four checks means "not
currently tripped," not "untested."
"""

import os
import re
import shutil
import subprocess
from dataclasses import dataclass

MachOKey = tuple[str, str]
"""A Mach-O file identity: ``(path, arch)``. ``arch`` is ``""`` for a thin binary."""

_ARCH_RE = re.compile(r"^(.*) \(architecture ([^)]+)\)$")
_EXEMPT_PREFIXES = ("/usr/lib", "/System")
_LINUX_EXEMPT_PREFIXES = ("/lib", "/lib64", "/usr/lib", "/usr/lib64")
_LDD_ADDRESS_SUFFIX_RE = re.compile(r" \(0x[0-9a-fA-F]+\)$")
_LOADER_ENV_VARS = ("LD_LIBRARY_PATH", "LD_PRELOAD", "LD_AUDIT")
_MACHO_SUBDIRS = ("bin", "libexec/bin", "lib", "lib64", "libexec/lib")
_PKGCONFIG_SUBDIRS = ("lib/pkgconfig", "lib64/pkgconfig", "share/pkgconfig")
_PC_BUILD_KEYS = (
    "Cflags:",
    "Cflags.private:",
    "Libs:",
    "Libs.private:",
    "Requires:",
    "Requires.private:",
)
_CHECK_LABELS = {
    "dangling": "dangling absolute dependency",
    "rpath": "unresolvable dependency",
    "relative": "relative path",
    "foreign": "foreign prefix leak",
    "stale": "stale dependency version",
    "pkgconfig": "dangling pkg-config path",
}


@dataclass(frozen=True, slots=True)
class Finding:
    """A single linkage problem found in an installed app.

    Attributes
    ----------
    app : str
        Name of the owning koopa app.
    path : str
        Absolute path to the offending Mach-O file or ``.pc`` file.
    check : str
        Check bucket, one of the keys in ``_CHECK_LABELS``.
    detail : str
        The offending dependency, install name, or pkg-config path.
    reason : str
        Human-readable explanation of the problem.
    """

    app: str
    path: str
    check: str
    detail: str
    reason: str


# -- Pure parsers (no subprocess; unit-testable from canned otool text) ------


def parse_otool_header(line: str) -> MachOKey | None:
    """Parse an otool output header line into a Mach-O key.

    Parameters
    ----------
    line : str
        A single line of otool output.

    Returns
    -------
    MachOKey | None
        ``(path, arch)`` when *line* is a header line, otherwise ``None``.
        ``otool`` writes errors (e.g. "is not an object file") to stdout as
        a non-header line, which this correctly rejects.
    """
    if line.startswith(("\t", " ")):
        return None
    if not line.endswith(":"):
        return None
    body = line[:-1]
    match = _ARCH_RE.match(body)
    if match:
        return (match.group(1), match.group(2))
    return (body, "")


def parse_otool_dependencies(output: str) -> dict[MachOKey, list[str]]:
    """Parse ``otool -L`` output into per-file dependency lists.

    For a dylib, index 0 of the returned list is that dylib's own install
    name (from ``LC_ID_DYLIB``), not a dependency. Callers must suppress it
    using :func:`parse_otool_install_names` output for the same key.

    Parameters
    ----------
    output : str
        Captured stdout from an ``otool -L`` invocation.

    Returns
    -------
    dict[MachOKey, list[str]]
        Mapping of Mach-O key to its ordered dependency list, with the
        ``(compatibility version ...)`` suffix stripped from each entry.
    """
    deps: dict[MachOKey, list[str]] = {}
    key: MachOKey | None = None
    for line in output.splitlines():
        header = parse_otool_header(line)
        if header is not None:
            key = header
            deps[key] = []
            continue
        if key is None or not line.startswith("\t"):
            continue
        entry = line.strip().split(" (compatibility", 1)[0].strip()
        deps[key].append(entry)
    return deps


def parse_otool_install_names(output: str) -> dict[MachOKey, str]:
    """Parse ``otool -D`` output into per-file install names.

    Parameters
    ----------
    output : str
        Captured stdout from an ``otool -D`` invocation, run against dylibs
        only. Executables have no ``LC_ID_DYLIB`` and produce no entry.

    Returns
    -------
    dict[MachOKey, str]
        Mapping of Mach-O key to its own install name.
    """
    names: dict[MachOKey, str] = {}
    key: MachOKey | None = None
    for line in output.splitlines():
        header = parse_otool_header(line)
        if header is not None:
            key = header
            continue
        if key is None:
            continue
        stripped = line.strip()
        if not stripped:
            continue
        names[key] = stripped
        key = None
    return names


def parse_otool_rpaths(output: str) -> dict[MachOKey, list[str]]:
    """Parse ``otool -l`` output into per-file RPATH entries.

    Unlike ``build._extract_rpath_macos()``, this keeps ``@``-relative
    entries (e.g. ``@loader_path/../lib``) and records a file with zero
    ``LC_RPATH`` load commands as an empty list, not a missing key.

    Parameters
    ----------
    output : str
        Captured stdout from an ``otool -l`` invocation.

    Returns
    -------
    dict[MachOKey, list[str]]
        Mapping of Mach-O key to its ordered, de-duplicated RPATH entries.
    """
    rpaths: dict[MachOKey, list[str]] = {}
    key: MachOKey | None = None
    pending = False
    for line in output.splitlines():
        header = parse_otool_header(line)
        if header is not None:
            key = header
            rpaths[key] = []
            pending = False
            continue
        if key is None:
            continue
        stripped = line.strip()
        if stripped == "cmd LC_RPATH":
            pending = True
            continue
        if pending and stripped.startswith("path "):
            value = stripped[len("path ") :].split(" (offset", 1)[0].strip()
            if value and value not in rpaths[key]:
                rpaths[key].append(value)
            pending = False
    return rpaths


def expand_at_path(entry: str, binary_dir: str) -> str:
    """Expand an ``@loader_path``/``@executable_path`` reference.

    Parameters
    ----------
    entry : str
        An RPATH entry or dependency path.
    binary_dir : str
        Directory containing the binary that referenced *entry*.

    Returns
    -------
    str
        *entry* unchanged when it is not ``@loader_path``/``@executable_path``
        relative; otherwise the expanded, normalized absolute path.
    """
    for token in ("@loader_path", "@executable_path"):
        if entry == token:
            return os.path.normpath(binary_dir)
        if entry.startswith(token + "/"):
            return os.path.normpath(binary_dir + entry[len(token) :])
    return entry


def parse_pc_koopa_paths(text: str, app_root: str) -> list[str]:
    """Extract koopa app-prefix paths that actually feed a build.

    Scoped to ``Cflags``/``Libs``/``Requires`` (and their ``.private``
    variants) — the only keys a real ``pkg-config --cflags``/``--libs``
    call ever reads. A vendored conda package's ``.pc`` file routinely
    carries its own custom runtime-only variables (a D-Bus socket address,
    a CA-bundle search path, an X11 app-defaults directory) that happen to
    embed a koopa app-prefix path and happen not to exist yet — inert
    metadata no build consumes, not a linkage problem.

    Parameters
    ----------
    text : str
        Contents of a ``.pc`` file.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``). An unexpanded
        ``${libdir}``-style reference never starts with this literal path
        and is naturally ignored.

    Returns
    -------
    list[str]
        De-duplicated paths found under *app_root* on a build-relevant
        line, in first-seen order, with trailing punctuation stripped.
    """
    pattern = re.compile(re.escape(app_root) + r"/[^\s:'\"<>()]+")
    seen: list[str] = []
    for line in text.splitlines():
        if not line.startswith(_PC_BUILD_KEYS):
            continue
        for match in pattern.finditer(line):
            path = match.group(0).rstrip("/,;")
            if path not in seen:
                seen.append(path)
    return seen


def parse_ldd_output(output: str) -> dict[str, str | None]:
    """Parse ``ldd``'s trace output into a dependency-name/resolved-path map.

    Verified against glibc's own trace printer (``elf/rtld.c``), which emits
    three tab-prefixed line shapes: ``"%s => not found"`` for an unresolved
    dependency, ``"%s => %s (0xADDR)"`` for a resolved one, and a bare
    ``"%s (0xADDR)"`` with no ``=>`` for the vDSO pseudo-entry (and, rarely,
    a ``DT_NEEDED`` entry that is itself an absolute path resolving to
    itself). A statically-linked binary emits only ``"statically linked"``.

    Parameters
    ----------
    output : str
        Captured stdout from an ``ldd`` invocation against one file.

    Returns
    -------
    dict[str, str | None]
        Mapping of each dependency's raw, unexpanded name (the literal
        ``DT_NEEDED`` string, usually a bare soname) to its resolved
        absolute path, or ``None`` when ``ldd`` reported it as
        "not found". A statically-linked binary, or a vDSO-style entry
        with no backing file on disk, contributes no entries.
    """
    deps: dict[str, str | None] = {}
    for raw_line in output.splitlines():
        line = raw_line.strip()
        if not line or line == "statically linked":
            continue
        if " => not found" in line:
            deps[line.split(" => not found", 1)[0].strip()] = None
            continue
        if " => " in line:
            name, rest = line.split(" => ", 1)
            deps[name.strip()] = _LDD_ADDRESS_SUFFIX_RE.sub("", rest.strip())
            continue
        candidate = _LDD_ADDRESS_SUFFIX_RE.sub("", line).strip()
        if os.path.exists(candidate):
            deps[candidate] = candidate
    return deps


# -- Classifier ----------------------------------------------------------


def _classify_rpath(name: str, binary_dir: str, rpaths: list[str]) -> tuple[str, str] | None:
    """Classify an ``@rpath/`` dependency against a binary's RPATH entries.

    Parameters
    ----------
    name : str
        The dependency's basename (the part after ``@rpath/``).
    binary_dir : str
        Directory containing the binary that references *name*.
    rpaths : list[str]
        Raw ``LC_RPATH`` entries for this binary, from
        :func:`parse_otool_rpaths`.

    Returns
    -------
    tuple[str, str] | None
        ``("rpath", ...)`` when unresolvable, otherwise ``None``.
    """
    if not rpaths:
        return ("rpath", "no LC_RPATH entries")
    for entry in rpaths:
        if os.path.exists(os.path.join(expand_at_path(entry, binary_dir), name)):
            return None
    return (
        "rpath",
        f"none of {len(rpaths)} LC_RPATH entries contain it; "
        "dyld will fall back to a system library",
    )


def _classify_koopa_path(
    dep: str, app_root: str, current: dict[str, str]
) -> tuple[str, str] | None:
    """Classify an absolute, non-exempt dependency path.

    Parameters
    ----------
    dep : str
        An absolute dependency path, already known not to be under
        ``/usr/lib`` or ``/System``.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).
    current : dict[str, str]
        Mapping of koopa app name to its currently ``opt/``-linked version.

    Returns
    -------
    tuple[str, str] | None
        ``(check, reason)`` when *dep* is a problem, otherwise ``None``.
    """
    if not dep.startswith(app_root + "/"):
        return ("foreign", f"'{dep}' is outside the koopa app prefix")
    if not os.path.exists(dep):
        return ("dangling", f"'{dep}' does not exist")
    parts = dep[len(app_root) + 1 :].split("/", 2)
    if len(parts) < 2:
        return None
    dep_name, dep_version = parts[0], parts[1]
    cur = current.get(dep_name)
    if cur is None:
        return ("stale", f"links {dep_name}, which has no opt/ symlink")
    if dep_version != cur:
        return ("stale", f"links {dep_name} {dep_version}, but opt/{dep_name} is {cur}")
    return None


def classify_dependency(
    dep: str,
    *,
    binary_dir: str,
    rpaths: list[str],
    app_root: str,
    current: dict[str, str],
) -> tuple[str, str] | None:
    """Classify a single dependency reference from a Mach-O file.

    Parameters
    ----------
    dep : str
        One ``LC_LOAD_DYLIB`` entry (a dependency path or ``@``-reference).
    binary_dir : str
        Directory containing the binary that references *dep*.
    rpaths : list[str]
        Raw ``LC_RPATH`` entries for this binary, from
        :func:`parse_otool_rpaths`.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).
    current : dict[str, str]
        Mapping of koopa app name to its currently ``opt/``-linked version.

    Returns
    -------
    tuple[str, str] | None
        ``(check, reason)`` when *dep* is a problem, otherwise ``None``.
    """
    if dep.startswith("@rpath/"):
        return _classify_rpath(dep[len("@rpath/") :], binary_dir, rpaths)
    if dep.startswith("@"):
        if os.path.exists(expand_at_path(dep, binary_dir)):
            return None
        return ("dangling", f"'{dep}' does not resolve under {binary_dir}")
    if not dep.startswith("/"):
        return ("relative", "dependency path is relative to the process cwd")
    if dep.startswith(_EXEMPT_PREFIXES):
        return None
    return _classify_koopa_path(dep, app_root, current)


def classify_install_name(install_name: str) -> tuple[str, str] | None:
    """Classify a dylib's own install name.

    Parameters
    ----------
    install_name : str
        The ``LC_ID_DYLIB`` value for a dylib, from
        :func:`parse_otool_install_names`.

    Returns
    -------
    tuple[str, str] | None
        ``("relative", ...)`` when *install_name* is relative to the
        process cwd, otherwise ``None``.
    """
    if install_name.startswith(("/", "@")):
        return None
    return ("relative", f"dylib's own install name is relative: '{install_name}'")


def classify_resolved_dependency(
    name: str,
    resolved_path: str | None,
    *,
    app_root: str,
    current: dict[str, str],
) -> tuple[str, str] | None:
    """Classify one ``ldd``-resolved ELF dependency (Linux).

    Unlike :func:`classify_dependency` (Mach-O), *name* is not itself
    classified: on Linux a dependency is normally a bare soname with no
    path shape at all, and ``ldd`` has already done the real RPATH/RUNPATH/
    ld.so.cache resolution work. Only the outcome of that resolution is
    classified here.

    Parameters
    ----------
    name : str
        The dependency's raw, unexpanded name (the literal ``DT_NEEDED``
        string), from :func:`parse_ldd_output`.
    resolved_path : str | None
        The absolute path ``ldd`` resolved *name* to, or ``None`` when
        ``ldd`` reported it as "not found".
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).
    current : dict[str, str]
        Mapping of koopa app name to its currently ``opt/``-linked version.

    Returns
    -------
    tuple[str, str] | None
        ``(check, reason)`` when this dependency is a problem, otherwise
        ``None``.
    """
    if resolved_path is None:
        if name.startswith("/"):
            return ("dangling", f"'{name}' does not exist")
        return (
            "rpath",
            f"ldd could not resolve '{name}' via RPATH/RUNPATH or the system default paths",
        )
    if resolved_path.startswith(_LINUX_EXEMPT_PREFIXES):
        return None
    return _classify_koopa_path(resolved_path, app_root, current)


# -- I/O + enumeration ---------------------------------------------------


def _run_otool(flag: str, files: list[str], *, batch: int = 150) -> str:
    """Run otool over a list of files in batches.

    Parameters
    ----------
    flag : str
        The otool flag to pass (``"-L"``, ``"-D"``, or ``"-l"``).
    files : list[str]
        Absolute paths to inspect.
    batch : int, optional
        Maximum number of files per ``otool`` invocation.

    Returns
    -------
    str
        Concatenated stdout across all batches. ``otool`` writes errors
        (e.g. a non-Mach-O input) to stdout and exits 0, so ``check=True``
        is safe here.
    """
    otool = shutil.which("otool")
    if otool is None:
        msg = "otool is not installed."
        raise RuntimeError(msg)
    chunks: list[str] = []
    for i in range(0, len(files), batch):
        result = subprocess.run(
            [otool, flag, *files[i : i + batch]],
            capture_output=True,
            text=True,
            check=True,
        )
        chunks.append(result.stdout)
    return "\n".join(chunks)


def _is_elf(path: str) -> bool:
    """Return True when the file at *path* starts with the ELF magic bytes.

    A self-contained copy of the same check ``install.py::_is_elf()``
    already makes for a different, narrower purpose (the conda-package
    linkage gate). Duplicated rather than imported, matching this module's
    existing choice to keep its own parsers self-contained rather than
    reach into ``build.py``/``install.py`` internals.

    Parameters
    ----------
    path : str
        Path to the file to check.

    Returns
    -------
    bool
        True when the file starts with the ELF magic bytes.
    """
    try:
        with open(path, "rb") as fh:
            return fh.read(4) == b"\x7fELF"
    except OSError:
        return False


def _clean_ldd_env() -> dict[str, str]:
    """Build a subprocess environment with loader-influencing vars removed.

    Without this, ``ldd``'s result depends on whatever ``LD_LIBRARY_PATH``/
    ``LD_PRELOAD``/``LD_AUDIT`` happen to be set in the calling shell, which
    would make the audit reflect ambient environment pollution rather than
    a binary's own RPATH/RUNPATH wiring: exactly the class of bug this
    command exists to catch.

    Returns
    -------
    dict[str, str]
        A copy of the current process environment with every entry in
        ``_LOADER_ENV_VARS`` removed.
    """
    env = dict(os.environ)
    for var in _LOADER_ENV_VARS:
        env.pop(var, None)
    return env


def _run_ldd(path: str) -> str:
    """Run ``ldd`` against a single ELF file with a clean loader environment.

    Batching (as :func:`_run_otool` does) is deliberately not used here.
    ``ldd`` does support multiple file arguments, printing a ``"<path>:"``
    header before each file's block when more than one file is given
    (verified against glibc's ``elf/ldd.bash.in``) — but a single
    incompatible-architecture or corrupt file in a batch makes the whole
    invocation's exit status non-zero (verified against the same source),
    and this function must never let one bad file take down the audit of
    every other file in its batch. Calling per-file, matching the existing,
    tested convention in ``install.py::_missing_shared_libs()``, avoids
    that failure mode entirely.

    Parameters
    ----------
    path : str
        Path to the ELF file to inspect.

    Returns
    -------
    str
        Captured stdout, or ``""`` if ``ldd`` timed out or could not be run.
        ``check=False`` is deliberate: unlike the pre-filtered, already-
        trusted single-file caller in ``install.py``, this function may see
        a wrong-architecture or otherwise incompatible file and must not
        raise on that.
    """
    ldd = shutil.which("ldd")
    if ldd is None:
        msg = "ldd is not installed."
        raise RuntimeError(msg)
    try:
        result = subprocess.run(
            [ldd, path],
            capture_output=True,
            text=True,
            check=False,
            timeout=30,
            env=_clean_ldd_env(),
        )
    except (subprocess.TimeoutExpired, OSError):
        return ""
    return result.stdout


def _current_app_prefixes() -> dict[str, str]:
    """Resolve every installed app's current ``opt/``-linked prefix.

    Returns
    -------
    dict[str, str]
        Mapping of app name to its resolved, currently-linked prefix
        directory. An app with a broken ``opt/`` symlink is omitted;
        ``check_broken_symlinks()`` is responsible for flagging that.
    """
    from koopa.app import installed_apps
    from koopa.build import app_prefix as resolve_app_prefix

    prefixes: dict[str, str] = {}
    for name in installed_apps():
        resolved = resolve_app_prefix(name)
        if os.path.isdir(resolved):
            prefixes[name] = resolved
    return prefixes


def _macho_candidates(prefixes: dict[str, str]) -> tuple[list[str], dict[str, str]]:
    """Enumerate Mach-O candidate files under each app's current prefix.

    Parameters
    ----------
    prefixes : dict[str, str]
        Mapping of app name to its resolved prefix directory.

    Returns
    -------
    tuple[list[str], dict[str, str]]
        A sorted, realpath-deduplicated file list, and a mapping of each
        file's realpath to its owning app name. Symlinked entries (e.g. a
        versioned dylib symlink chain) are skipped during listing so only
        the real regular file is counted.
    """
    owners: dict[str, str] = {}
    for name, prefix in prefixes.items():
        for sub in _MACHO_SUBDIRS:
            directory = os.path.join(prefix, sub)
            if not os.path.isdir(directory):
                continue
            try:
                entries = sorted(os.listdir(directory))
            except OSError:
                continue
            for entry in entries:
                path = os.path.join(directory, entry)
                if os.path.islink(path) or not os.path.isfile(path):
                    continue
                owners.setdefault(os.path.realpath(path), name)
    return sorted(owners), owners


def _pkgconfig_candidates(prefixes: dict[str, str]) -> list[tuple[str, str]]:
    """Enumerate pkg-config files under each app's current prefix.

    Deliberately not ``build._find_pc_files()``, which recurses the whole
    prefix tree: that reaches e.g. a conda app's ``libexec/lib/pkgconfig``,
    a directory no real build's ``PKG_CONFIG_PATH`` ever includes (see
    ``build._add_pkg_config_paths()``, which only ever adds the three
    directories below). Scanning it produced false-positive dangling-path
    findings for vendored ``.pc`` files no build would ever read.

    Parameters
    ----------
    prefixes : dict[str, str]
        Mapping of app name to its resolved prefix directory.

    Returns
    -------
    list[tuple[str, str]]
        ``(app_name, pc_path)`` pairs, restricted to the same
        ``lib/pkgconfig``, ``lib64/pkgconfig``, and ``share/pkgconfig``
        directories that ``PKG_CONFIG_PATH`` actually searches.
    """
    pairs: list[tuple[str, str]] = []
    for name, prefix in prefixes.items():
        for sub in _PKGCONFIG_SUBDIRS:
            directory = os.path.join(prefix, sub)
            if not os.path.isdir(directory):
                continue
            try:
                entries = sorted(os.listdir(directory))
            except OSError:
                continue
            for entry in entries:
                if entry.endswith(".pc"):
                    pairs.append((name, os.path.join(directory, entry)))
    return pairs


def _audit_pkgconfig(pairs: list[tuple[str, str]], app_root: str) -> list[Finding]:
    """Audit pkg-config files for dangling koopa app-prefix paths.

    Parameters
    ----------
    pairs : list[tuple[str, str]]
        ``(app_name, pc_path)`` pairs from :func:`_pkgconfig_candidates`.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).

    Returns
    -------
    list[Finding]
        One finding per embedded koopa path that does not exist on disk.
    """
    findings: list[Finding] = []
    for name, pc_path in pairs:
        try:
            with open(pc_path, encoding="utf-8", errors="replace") as fh:
                text = fh.read()
        except OSError:
            continue
        for dep_path in parse_pc_koopa_paths(text, app_root):
            if not os.path.exists(dep_path):
                findings.append(
                    Finding(name, pc_path, "pkgconfig", dep_path, f"'{dep_path}' does not exist")
                )
    return findings


# -- Platform dispatch ----------------------------------------------------


def _audit_macho(
    files: list[str],
    owners: dict[str, str],
    app_root: str,
    current: dict[str, str],
) -> list[Finding]:
    """Dispatch a Mach-O/ELF linkage audit by platform.

    Parameters
    ----------
    files : list[str]
        Candidate binary/library files to inspect.
    owners : dict[str, str]
        Mapping of file realpath to owning app name.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).
    current : dict[str, str]
        Mapping of koopa app name to its currently ``opt/``-linked version.

    Returns
    -------
    list[Finding]
        Findings from the platform-appropriate backend.
    """
    from koopa.system import is_macos

    if is_macos():
        return _audit_macho_macos(files, owners, app_root, current)
    return _audit_macho_linux(files, owners, app_root, current)


def _audit_macho_macos(
    files: list[str],
    owners: dict[str, str],
    app_root: str,
    current: dict[str, str],
) -> list[Finding]:
    """Audit Mach-O files for linkage problems via otool.

    Parameters
    ----------
    files : list[str]
        Candidate binary/library files to inspect.
    owners : dict[str, str]
        Mapping of file realpath to owning app name.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).
    current : dict[str, str]
        Mapping of koopa app name to its currently ``opt/``-linked version.

    Returns
    -------
    list[Finding]
        De-duplicated findings, collapsed across architectures of the same
        fat binary.
    """
    if not files:
        return []
    dylibs = [f for f in files if f.endswith((".dylib", ".so"))]
    deps = parse_otool_dependencies(_run_otool("-L", files))
    rpaths = parse_otool_rpaths(_run_otool("-l", files))
    names = parse_otool_install_names(_run_otool("-D", dylibs)) if dylibs else {}

    findings: list[Finding] = []
    for key, dep_list in deps.items():
        path, _arch = key
        own_name = names.get(key)
        is_own_name = dep_list and own_name is not None and dep_list[0] == own_name
        entries = dep_list[1:] if is_own_name else dep_list
        app = owners.get(path, "?")
        binary_dir = os.path.dirname(path)
        rp = rpaths.get(key, [])
        for dep in entries:
            verdict = classify_dependency(
                dep, binary_dir=binary_dir, rpaths=rp, app_root=app_root, current=current
            )
            if verdict is not None:
                check, reason = verdict
                findings.append(Finding(app, path, check, dep, reason))
    for key, install_name in names.items():
        verdict = classify_install_name(install_name)
        if verdict is not None:
            check, reason = verdict
            findings.append(Finding(owners.get(key[0], "?"), key[0], check, install_name, reason))
    return list(dict.fromkeys(findings))


def _audit_macho_linux(
    files: list[str],
    owners: dict[str, str],
    app_root: str,
    current: dict[str, str],
) -> list[Finding]:
    """Audit ELF files for linkage problems via ldd.

    Unverified against a real Linux host as of this writing; see the
    module docstring's verification note.

    Parameters
    ----------
    files : list[str]
        Candidate binary/library files to inspect.
    owners : dict[str, str]
        Mapping of file realpath to owning app name.
    app_root : str
        The koopa app prefix (``<koopa_prefix>/app``).
    current : dict[str, str]
        Mapping of koopa app name to its currently ``opt/``-linked version.

    Returns
    -------
    list[Finding]
        One finding per unresolvable, dangling, foreign, or stale
        dependency. Non-ELF candidates (a shell script wrapper, a data
        file) are silently skipped.
    """
    findings: list[Finding] = []
    for path in files:
        if not _is_elf(path):
            continue
        deps = parse_ldd_output(_run_ldd(path))
        app = owners.get(path, "?")
        for name, resolved in deps.items():
            verdict = classify_resolved_dependency(
                name, resolved, app_root=app_root, current=current
            )
            if verdict is not None:
                check, reason = verdict
                findings.append(Finding(app, path, check, name, reason))
    return findings


# -- Orchestration ---------------------------------------------------------


def linker_check(apps: list[str] | None = None) -> bool:
    """Audit installed apps for Mach-O linkage problems.

    Parameters
    ----------
    apps : list[str] | None, optional
        Limit the audit to these app names. Defaults to every installed
        app.

    Returns
    -------
    bool
        True when no problems were found.
    """
    from koopa.alert import alert, alert_success, dl
    from koopa.prefix import app_prefix as koopa_app_root

    all_prefixes = _current_app_prefixes()
    current = {name: os.path.basename(prefix) for name, prefix in all_prefixes.items()}
    prefixes = all_prefixes
    if apps:
        unknown = sorted(a for a in apps if a not in prefixes)
        if unknown:
            msg = f"Unknown or not installed: {', '.join(unknown)}."
            raise ValueError(msg)
        prefixes = {name: prefixes[name] for name in prefixes if name in apps}

    app_root = koopa_app_root()
    files, owners = _macho_candidates(prefixes)
    pc_pairs = _pkgconfig_candidates(prefixes)

    findings = _audit_macho(files, owners, app_root, current) + _audit_pkgconfig(pc_pairs, app_root)

    n_apps = len(prefixes)
    alert(f"Checking Mach-O linkage for {n_apps} installed app{'' if n_apps == 1 else 's'}.")
    if not findings:
        alert_success("No Mach-O linkage problems found.")
        return True

    for finding in findings:
        base = prefixes.get(finding.app, app_root)
        rel = os.path.relpath(finding.path, base)
        print(f"{finding.app}: {rel}: {finding.reason}")

    affected = len({f.app for f in findings})
    n = len(findings)
    alert(
        f"{n} finding{'' if n == 1 else 's'} in {affected} of {n_apps} apps "
        f"({len(files)} Mach-O files, {len(pc_pairs)} pkg-config files)."
    )
    for check, label in _CHECK_LABELS.items():
        count = sum(1 for f in findings if f.check == check)
        dl(label, str(count))
    return False
