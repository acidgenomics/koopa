"""Build orchestration helpers for Python-native installers.

Provides ``activate_app``, ``cmake_build``, and ``make_build`` — the
Python equivalents of the Bash functions ``_koopa_activate_app``,
``_koopa_cmake_build``, and ``_koopa_make_build``.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path


def _koopa_prefix() -> str:
    """Return koopa installation prefix."""
    return os.environ.get("KOOPA_PREFIX", str(Path(__file__).resolve().parents[4]))


def _opt_prefix() -> str:
    """Return koopa opt prefix."""
    return os.path.join(_koopa_prefix(), "opt")


def _app_prefix() -> str:
    """Return koopa app prefix."""
    return os.path.join(_koopa_prefix(), "app")


def _cpu_count() -> int:
    """Return CPU count."""
    return os.cpu_count() or 1


def _is_macos() -> bool:
    """Check if running on macOS."""
    return sys.platform == "darwin"


def _shared_ext() -> str:
    """Return shared library extension for current platform."""
    return "dylib" if _is_macos() else "so"


# -- BuildEnv -----------------------------------------------------------------


@dataclass
class BuildEnv:
    """Accumulated build environment variables.

    Replaces the Bash pattern of exporting env vars during
    ``_koopa_activate_app`` calls. Variables accumulate across multiple
    ``activate_app`` calls and are applied to subprocess invocations via
    ``to_env_dict``.
    """

    path: list[str] = field(default_factory=list)
    cppflags: list[str] = field(default_factory=list)
    ldflags: list[str] = field(default_factory=list)
    ldlibs: list[str] = field(default_factory=list)
    library_path: list[str] = field(default_factory=list)
    pkg_config_path: list[str] = field(default_factory=list)
    cmake_prefix_path: list[str] = field(default_factory=list)

    def to_env_dict(self) -> dict[str, str]:
        """Convert to a dict suitable for ``subprocess`` ``env`` param.

        Merges accumulated values with the current ``os.environ``, placing
        our values at the front of each path variable.
        """
        env = os.environ.copy()
        if self.path:
            existing = env.get("PATH", "")
            env["PATH"] = _merge_colon(self.path, existing)
        if self.cppflags:
            existing = env.get("CPPFLAGS", "")
            env["CPPFLAGS"] = _merge_space(self.cppflags, existing)
        if self.ldflags:
            existing = env.get("LDFLAGS", "")
            env["LDFLAGS"] = _merge_space(self.ldflags, existing)
        if self.ldlibs:
            existing = env.get("LDLIBS", "")
            env["LDLIBS"] = _merge_space(self.ldlibs, existing)
        if self.library_path:
            existing = env.get("LIBRARY_PATH", "")
            env["LIBRARY_PATH"] = _merge_colon(self.library_path, existing)
        if self.pkg_config_path:
            existing = env.get("PKG_CONFIG_PATH", "")
            env["PKG_CONFIG_PATH"] = _merge_colon(self.pkg_config_path, existing)
        if self.cmake_prefix_path:
            existing = env.get("CMAKE_PREFIX_PATH", "")
            env["CMAKE_PREFIX_PATH"] = _merge_semicolon(self.cmake_prefix_path, existing)
        return env

    def apply(self) -> None:
        """Export accumulated values into ``os.environ``."""
        env = self.to_env_dict()
        for key in (
            "PATH",
            "CPPFLAGS",
            "LDFLAGS",
            "LDLIBS",
            "LIBRARY_PATH",
            "PKG_CONFIG_PATH",
            "CMAKE_PREFIX_PATH",
        ):
            if env.get(key):
                os.environ[key] = env[key]


def _merge_colon(new: list[str], existing: str) -> str:
    parts = new + [p for p in existing.split(":") if p]
    return ":".join(dict.fromkeys(parts))


def _merge_space(new: list[str], existing: str) -> str:
    parts = new + existing.split()
    return " ".join(dict.fromkeys(parts))


def _merge_semicolon(new: list[str], existing: str) -> str:
    parts = new + [p for p in existing.split(";") if p]
    return ";".join(dict.fromkeys(parts))


# -- activate_app -------------------------------------------------------------


def activate_app(
    *names: str,
    build_only: bool = False,
    env: BuildEnv | None = None,
) -> BuildEnv:
    """Activate installed apps for building.

    Resolves the installed prefix for each named app (via the ``opt/``
    symlink) and adds its bin, include, lib, and pkgconfig paths to the
    build environment.

    Parameters
    ----------
    names
        App names to activate (e.g. ``"zlib"``, ``"openssl"``).
    build_only
        If ``True``, only modify PATH and PKG_CONFIG_PATH — skip
        CPPFLAGS, LDFLAGS, LDLIBS, LIBRARY_PATH, and CMAKE_PREFIX_PATH.
    env
        Existing ``BuildEnv`` to accumulate into. A new one is created
        if not provided.

    Returns
    -------
    BuildEnv
        The (possibly new) build environment with paths added.
    """
    if env is None:
        env = BuildEnv()
    opt = _opt_prefix()
    for name in names:
        app_link = os.path.join(opt, name)
        if not os.path.exists(app_link):
            msg = f"App not installed: {name!r} (expected at {app_link})"
            raise FileNotFoundError(msg)
        prefix = os.path.realpath(app_link)
        bin_dir = os.path.join(prefix, "bin")
        if os.path.isdir(bin_dir):
            env.path.append(bin_dir)
        _add_pkg_config_paths(prefix, env)
        if build_only:
            continue
        include_dir = os.path.join(prefix, "include")
        lib_dir = os.path.join(prefix, "lib")
        lib64_dir = os.path.join(prefix, "lib64")
        pc_files = _find_pc_files(prefix)
        if pc_files:
            _add_flags_from_pkgconfig(pc_files, env)
        else:
            if os.path.isdir(include_dir):
                env.cppflags.append(f"-I{include_dir}")
            for ld in (lib_dir, lib64_dir):
                if os.path.isdir(ld):
                    env.ldflags.append(f"-L{ld}")
        for ld in (lib_dir, lib64_dir):
            if os.path.isdir(ld):
                env.ldflags.append(f"-Wl,-rpath,{ld}")
                env.library_path.append(ld)
        cmake_dir = os.path.join(prefix, "lib", "cmake")
        if os.path.isdir(cmake_dir):
            env.cmake_prefix_path.append(cmake_dir)
    return env


def _add_pkg_config_paths(prefix: str, env: BuildEnv) -> None:
    """Add pkgconfig directories to PKG_CONFIG_PATH."""
    candidates = [
        os.path.join(prefix, "lib", "pkgconfig"),
        os.path.join(prefix, "lib64", "pkgconfig"),
        os.path.join(prefix, "share", "pkgconfig"),
    ]
    for d in candidates:
        if os.path.isdir(d):
            env.pkg_config_path.append(d)


def _find_pc_files(prefix: str) -> list[str]:
    """Find all .pc files under a prefix."""
    result: list[str] = []
    for root, _dirs, files in os.walk(prefix):
        for f in files:
            if f.endswith(".pc"):
                result.append(os.path.join(root, f))
    return result


def _add_flags_from_pkgconfig(pc_files: list[str], env: BuildEnv) -> None:
    """Extract compiler/linker flags from .pc files via pkg-config."""
    pkg_config = shutil.which("pkg-config")
    if pkg_config is None:
        return
    pkg_names = [os.path.splitext(os.path.basename(f))[0] for f in pc_files]
    pc_dirs = list({os.path.dirname(f) for f in pc_files})
    pc_env = os.environ.copy()
    existing_pc = pc_env.get("PKG_CONFIG_PATH", "")
    all_pc_dirs = [*pc_dirs, *env.pkg_config_path]
    pc_env["PKG_CONFIG_PATH"] = ":".join([*all_pc_dirs, existing_pc])
    for pkg in pkg_names:
        try:
            cflags = subprocess.run(
                [pkg_config, "--cflags", pkg],
                capture_output=True,
                text=True,
                check=True,
                env=pc_env,
            ).stdout.strip()
            if cflags:
                env.cppflags.extend(cflags.split())
        except subprocess.CalledProcessError:
            pass
        try:
            ldflags = subprocess.run(
                [pkg_config, "--libs-only-L", pkg],
                capture_output=True,
                text=True,
                check=True,
                env=pc_env,
            ).stdout.strip()
            if ldflags:
                env.ldflags.extend(ldflags.split())
        except subprocess.CalledProcessError:
            pass
        try:
            ldlibs = subprocess.run(
                [pkg_config, "--libs-only-l", pkg],
                capture_output=True,
                text=True,
                check=True,
                env=pc_env,
            ).stdout.strip()
            if ldlibs:
                env.ldlibs.extend(ldlibs.split())
        except subprocess.CalledProcessError:
            pass


# -- cmake_build --------------------------------------------------------------


_NINJA_PROGRESS_RE = re.compile(r"^\[(\d+)/(\d+)\]")


def cmake_build(
    *,
    prefix: str,
    source_dir: str = ".",
    build_dir: str | None = None,
    args: list[str] | None = None,
    generator: str = "Unix Makefiles",
    jobs: int | None = None,
    env: BuildEnv | None = None,
) -> None:
    """Run cmake configure, build, and install.

    Parameters
    ----------
    prefix
        Installation prefix (``CMAKE_INSTALL_PREFIX``).
    source_dir
        Path to CMakeLists.txt directory.
    build_dir
        Build directory. Auto-generated if not specified.
    args
        Additional CMake cache variables (e.g. ``["-DFOO=ON"]``).
    generator
        CMake generator name (default ``"Unix Makefiles"``).  Automatically
        switched to ``"Ninja"`` when ``ninja`` is on PATH.
    jobs
        Parallel build jobs (defaults to CPU count).
    env
        Build environment from ``activate_app``.
    """
    if jobs is None:
        jobs = _cpu_count()
    cmake = shutil.which("cmake")
    if cmake is None:
        msg = "cmake not found."
        raise FileNotFoundError(msg)
    if generator == "Unix Makefiles" and shutil.which("ninja"):
        generator = "Ninja"
    auto_build_dir = False
    if build_dir is None:
        build_dir = tempfile.mkdtemp(prefix="koopa-cmake-")
        auto_build_dir = True
    else:
        os.makedirs(build_dir, exist_ok=True)
    subprocess_env = env.to_env_dict() if env else os.environ.copy()
    cmake_args = _cmake_std_args(
        prefix=prefix,
        generator=generator,
        subprocess_env=subprocess_env,
    )
    if args:
        cmake_args.extend(args)
    try:
        subprocess.run(
            [
                cmake,
                "-LH",
                "-B",
                build_dir,
                "-G",
                generator,
                "-S",
                source_dir,
                *cmake_args,
            ],
            env=subprocess_env,
            check=True,
        )
        _cmake_build_step(
            cmake=cmake,
            build_dir=build_dir,
            jobs=jobs,
            subprocess_env=subprocess_env,
            use_ninja=generator == "Ninja",
        )
        subprocess.run(
            [cmake, "--install", build_dir, "--prefix", prefix],
            env=subprocess_env,
            check=True,
        )
    finally:
        if auto_build_dir:
            shutil.rmtree(build_dir, ignore_errors=True)


def _run_ninja_with_progress(
    cmd: list[str],
    *,
    env: dict[str, str],
) -> None:
    """Run a command that produces ninja ``[current/total]`` progress output."""
    from koopa.progress import get_active_progress

    progress = get_active_progress()
    if progress is not None and progress._verbose:
        subprocess.run(cmd, env=env, check=True)
        return
    proc = subprocess.Popen(
        cmd,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    switched = False
    output_lines: list[str] = []
    assert proc.stdout is not None
    for line in proc.stdout:
        output_lines.append(line)
        m = _NINJA_PROGRESS_RE.match(line)
        if m and progress is not None:
            current, total = int(m.group(1)), int(m.group(2))
            if not switched:
                switched = progress.switch_to_step_mode(total)
            progress.update_steps(current, total)
        elif not switched:
            sys.stderr.write(line)
    rc = proc.wait()
    if rc != 0:
        sys.stderr.writelines(output_lines)
        raise subprocess.CalledProcessError(rc, cmd)


def _cmake_build_step(
    *,
    cmake: str,
    build_dir: str,
    jobs: int,
    subprocess_env: dict[str, str],
    use_ninja: bool,
) -> None:
    """Run the ``cmake --build`` step, optionally parsing Ninja progress."""
    cmd = [cmake, "--build", build_dir, "--parallel", str(jobs)]
    if not use_ninja:
        subprocess.run(cmd, env=subprocess_env, check=True)
        return
    _run_ninja_with_progress(cmd, env=subprocess_env)


def _cmake_std_args(
    *,
    prefix: str,
    generator: str,
    subprocess_env: dict[str, str],
) -> list[str]:
    """Return standard CMake arguments."""
    args = [
        "-DCMAKE_BUILD_TYPE=Release",
        f"-DCMAKE_INSTALL_PREFIX={prefix}",
        f"-DCMAKE_INSTALL_BINDIR={prefix}/bin",
        f"-DCMAKE_INSTALL_INCLUDEDIR={prefix}/include",
        f"-DCMAKE_INSTALL_LIBDIR={prefix}/lib",
        f"-DCMAKE_INSTALL_RPATH={prefix}/lib",
        "-DCMAKE_VERBOSE_MAKEFILE=ON",
    ]
    cppflags = subprocess_env.get("CPPFLAGS", "")
    if cppflags:
        args.append(f"-DCMAKE_C_FLAGS={cppflags}")
        args.append(f"-DCMAKE_CXX_FLAGS={cppflags}")
    ldflags = subprocess_env.get("LDFLAGS", "")
    if ldflags:
        args.append(f"-DCMAKE_EXE_LINKER_FLAGS={ldflags}")
        args.append(f"-DCMAKE_MODULE_LINKER_FLAGS={ldflags}")
        args.append(f"-DCMAKE_SHARED_LINKER_FLAGS={ldflags}")
    cmake_prefix = subprocess_env.get("CMAKE_PREFIX_PATH", "")
    if cmake_prefix:
        args.append(f"-DCMAKE_PREFIX_PATH={cmake_prefix}")
    if _is_macos():
        args.append("-DCMAKE_MACOSX_RPATH=ON")
        sdk = _macos_sdk_prefix()
        if sdk:
            args.append(f"-DCMAKE_OSX_SYSROOT={sdk}")
    return args


def _macos_sdk_prefix() -> str:
    """Return macOS SDK path."""
    try:
        result = subprocess.run(
            ["xcrun", "--sdk", "macosx", "--show-sdk-path"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError, FileNotFoundError:
        return ""


# -- make_build ---------------------------------------------------------------


def make_build(
    *,
    conf_args: list[str] | None = None,
    jobs: int | None = None,
    targets: list[str] | None = None,
    env: BuildEnv | None = None,
) -> None:
    """Run ``./configure && make && make install``.

    Parameters
    ----------
    conf_args
        Arguments passed to ``./configure``.
    jobs
        Parallel make jobs (defaults to CPU count).
    targets
        Make targets to run after build (defaults to ``["install"]``).
    env
        Build environment from ``activate_app``.
    """
    if jobs is None:
        jobs = _cpu_count()
    if targets is None:
        targets = ["install"]
    make = shutil.which("make")
    if make is None:
        msg = "make not found."
        raise FileNotFoundError(msg)
    subprocess_env = env.to_env_dict() if env else os.environ.copy()
    all_conf_args = list(conf_args or [])
    if os.path.isfile("./configure"):
        subprocess.run(
            ["./configure", *all_conf_args],
            env=subprocess_env,
            check=True,
        )
    subprocess.run(
        [make, f"-j{jobs}", "VERBOSE=1"],
        env=subprocess_env,
        check=True,
    )
    for target in targets:
        subprocess.run(
            [make, target],
            env=subprocess_env,
            check=True,
        )


# -- meson_build --------------------------------------------------------------


def meson_build(
    *,
    prefix: str,
    args: list[str] | None = None,
    jobs: int | None = None,
    env: BuildEnv | None = None,
) -> None:
    """Run ``meson setup``, ``ninja``, and ``ninja install``.

    Parameters
    ----------
    prefix
        Installation prefix.
    args
        Additional meson setup arguments.
    jobs
        Parallel build jobs (defaults to CPU count).
    env
        Build environment from ``activate_app``.
    """
    if jobs is None:
        jobs = _cpu_count()
    meson = shutil.which("meson")
    ninja = shutil.which("ninja")
    if meson is None:
        msg = "meson not found."
        raise FileNotFoundError(msg)
    if ninja is None:
        msg = "ninja not found."
        raise FileNotFoundError(msg)
    subprocess_env = env.to_env_dict() if env else os.environ.copy()
    meson_args = [
        "--buildtype=release",
        "--default-library=shared",
        "--libdir=lib",
        f"--prefix={prefix}",
    ]
    if args:
        meson_args.extend(args)
    subprocess.run(
        [meson, "setup", *meson_args, "build"],
        env=subprocess_env,
        check=True,
    )
    _run_ninja_with_progress(
        [ninja, "-v", "-j", str(jobs), "-C", "build"],
        env=subprocess_env,
    )
    subprocess.run(
        [ninja, "-v", "-j", str(jobs), "-C", "build", "install"],
        env=subprocess_env,
        check=True,
    )


# -- Convenience re-exports ---------------------------------------------------


def app_prefix(name: str) -> str:
    """Return the resolved prefix for an installed app."""
    link = os.path.join(_opt_prefix(), name)
    return os.path.realpath(link)


def shared_ext() -> str:
    """Return shared library extension for current platform."""
    return _shared_ext()


def locate(name: str) -> str:
    """Locate an executable, preferring koopa bin/."""
    koopa_bin = os.path.join(_koopa_prefix(), "bin")
    candidate = os.path.join(koopa_bin, name)
    if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
        return candidate
    found = shutil.which(name)
    if found is None:
        msg = f"{name} not found."
        raise FileNotFoundError(msg)
    return found
