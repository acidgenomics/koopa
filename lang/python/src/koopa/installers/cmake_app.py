"""Install cmake."""

from __future__ import annotations

import os
import re
import subprocess
import sys

from koopa.build import _cmake_std_args, activate_app, app_prefix, locate
from koopa.installers._build_helper import download_extract_cd

_MAKE_PROGRESS_RE = re.compile(r"^\[\s*(\d+)%\]")


def _run_make_with_progress(cmd: list[str], *, env: dict[str, str]) -> None:
    """Run make, parsing ``[ XX%]`` progress lines into the progress tracker."""
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
        m = _MAKE_PROGRESS_RE.match(line)
        if m and progress is not None:
            pct = int(m.group(1))
            if not switched:
                switched = progress.switch_to_step_mode(100)
            progress.update_steps(pct, 100)
        elif not switched:
            sys.stderr.write(line)
    rc = proc.wait()
    if rc != 0:
        sys.stderr.writelines(output_lines)
        raise subprocess.CalledProcessError(rc, cmd)


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install cmake."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app("openssl3", env=env)
    make = locate("make")
    url = f"https://github.com/Kitware/CMake/releases/download/v{version}/cmake-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    if sys.platform != "darwin":
        jobs = 1
    # Cap bootstrap parallelism to avoid OOM on macOS; bootstrap compiles
    # cmake itself and 12+ parallel C++ jobs exhaust memory quickly.
    bootstrap_jobs = min(jobs, 4)
    openssl_root = app_prefix("openssl3")
    cmake_args = _cmake_std_args(
        prefix=prefix,
        generator="Unix Makefiles",
        subprocess_env=subprocess_env,
    )
    # Strip verbose makefile flag so bootstrap-generated Makefile emits clean
    # [XX%] progress lines instead of full compiler commands.
    cmake_args = [a for a in cmake_args if "-DCMAKE_VERBOSE_MAKEFILE" not in a]
    cmake_args += [
        f"-DOPENSSL_ROOT_DIR={openssl_root}",
        "-DCMAKE_USE_OPENSSL=ON",
    ]
    bootstrap_args = [
        "--no-system-libs",
        f"--prefix={prefix}",
        f"--parallel={bootstrap_jobs}",
        "--",
        *cmake_args,
    ]
    subprocess.run(
        ["./bootstrap", *bootstrap_args],
        env=subprocess_env,
        check=True,
    )
    _run_make_with_progress(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
    cmake = os.path.join(prefix, "bin", "cmake")
    result = subprocess.run(
        [cmake, "--system-information"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert "CMAKE_USE_OPENSSL" in result.stdout, "CMake lacks TLS support"
