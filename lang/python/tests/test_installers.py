"""Installer registry unit tests."""

import os
from pathlib import Path
from types import ModuleType
from unittest.mock import patch

import pytest
from koopa.install import _app_json_installer
from koopa.installers import bcl_convert, cellranger, has_python_installer, neovim
from koopa.io import import_app_json

_BANNED_CPU_COUNT_PATTERNS = (
    "os.cpu_count(",
    "multiprocessing.cpu_count(",
    "from multiprocessing import cpu_count",
)


def test_no_installer_bypasses_koopa_cpu_count() -> None:
    """No installer computes a job count from os.cpu_count()/multiprocessing directly.

    koopa.system.cpu_count() is the single source of truth for how many build
    jobs koopa may spawn: it reads the current Slurm allocation
    (SLURM_CPUS_PER_TASK / SLURM_CPUS_ON_NODE) and clamps to the CPU affinity
    mask, so a stale KOOPA_CPU_COUNT can never oversubscribe a constrained
    allocation. An installer that reaches for os.cpu_count() or
    multiprocessing.cpu_count() instead silently loses all of that -- this is
    exactly the pattern that had 18 installers running 'make --jobs=96' on a
    single allocated Slurm CPU. Use 'from koopa.system import cpu_count'.
    """
    installers_dir = Path(cellranger.__file__).parent
    offenders = []
    for path in sorted(installers_dir.glob("*.py")):
        text = path.read_text()
        hits = [pattern for pattern in _BANNED_CPU_COUNT_PATTERNS if pattern in text]
        if hits:
            offenders.append(f"{path.name}: {hits}")
    assert not offenders, (
        "installer(s) bypass koopa.system.cpu_count() -- use"
        " 'from koopa.system import cpu_count' instead:\n" + "\n".join(offenders)
    )


def test_every_app_has_an_installer() -> None:
    """Every non-tombstoned app.json entry resolves to a Python installer."""
    unroutable = []
    for name, entry in sorted(import_app_json().items()):
        if not isinstance(entry, dict) or entry.get("removed"):
            continue
        if has_python_installer(name):
            continue
        key = _app_json_installer(name)
        if key and has_python_installer(key):
            continue
        unroutable.append(name)
    assert not unroutable, (
        "app.json entries with no Python installer: "
        f"{', '.join(unroutable)}. Add each to PYTHON_INSTALLERS in "
        "lang/python/src/koopa/installers/__init__.py."
    )


# -- private artifact preflight: cellranger, bcl-convert ----------------------


@pytest.mark.parametrize("installer_module", [cellranger, bcl_convert])
def test_private_artifact_installer_raises_with_staging_command_when_missing(
    installer_module: ModuleType,
) -> None:
    """Test that a missing staged artifact raises with the push-installer hint."""
    name = installer_module.__name__.rsplit(".", maxsplit=1)[-1].replace("_", "-")
    with (
        patch(
            "koopa.app.installer_artifact_key",
            return_value=f"installers/{name}/10.0.0.tar.xz",
        ),
        patch("koopa.aws.koopa_s3_bucket", return_value="artifacts-000000000000-us-east-1-an"),
        patch("koopa.aws.s3_object_exists", return_value=False),
        patch(
            "koopa.io.import_app_json",
            return_value={name: {"url": ["https://example.test/downloads"]}},
        ),
        pytest.raises(RuntimeError, match=f"koopa develop push-installer {name}"),
    ):
        installer_module.main(name=name, version="10.0.0", prefix="/tmp/unused-koopa-test")


@pytest.mark.parametrize("installer_module", [cellranger, bcl_convert])
def test_private_artifact_installer_raises_when_field_missing(
    installer_module: ModuleType,
) -> None:
    """Test that an app.json entry without 'installer_artifact' raises explicitly."""
    name = installer_module.__name__.rsplit(".", maxsplit=1)[-1].replace("_", "-")
    with (
        patch("koopa.app.installer_artifact_key", return_value=None),
        pytest.raises(RuntimeError, match="installer_artifact"),
    ):
        installer_module.main(name=name, version="10.0.0", prefix="/tmp/unused-koopa-test")


def test_cellranger_raises_when_archive_lacks_top_level_bin(tmp_path: Path) -> None:
    """Test that an extracted archive without a top-level 'bin/' raises explicitly.

    Guards against a silently dangling symlink: ``koopa.file_ops.ln()`` does not
    verify its source exists before calling ``symlink_to()``, so a vendor archive
    layout change would otherwise surface only much later as a bare
    'cellranger: command not found'.
    """
    prefix = str(tmp_path / "cellranger" / "10.0.0")
    with (
        patch(
            "koopa.app.installer_artifact_key",
            return_value="installers/cellranger/10.0.0.tar.xz",
        ),
        patch("koopa.aws.koopa_s3_bucket", return_value="artifacts-000000000000-us-east-1-an"),
        patch("koopa.aws.s3_object_exists", return_value=True),
        patch("koopa.installers.cellranger.subprocess.run"),
        patch("koopa.installers.cellranger.extract"),
        pytest.raises(RuntimeError, match="top-level 'bin/'"),
    ):
        cellranger.main(name="cellranger", version="10.0.0", prefix=prefix)


def test_cellranger_extracts_nested_vendor_tar(tmp_path: Path) -> None:
    """Test that Cell Ranger unpacks the nested tar in the vendor wrapper archive."""
    prefix = str(tmp_path / "cellranger" / "10.0.0")

    def mock_extract(path: str, output_dir: str) -> None:
        if path == "10.0.0.tar.xz":
            (Path(output_dir) / "cellranger-10.0.0.tar").touch()
        else:
            (Path(output_dir) / "bin").mkdir()

    with (
        patch(
            "koopa.app.installer_artifact_key",
            return_value="installers/cellranger/10.0.0.tar.xz",
        ),
        patch("koopa.aws.koopa_s3_bucket", return_value="artifacts-000000000000-us-east-1-an"),
        patch("koopa.aws.s3_object_exists", return_value=True),
        patch("koopa.installers.cellranger.subprocess.run"),
        patch("koopa.installers.cellranger.extract", side_effect=mock_extract) as extract_mock,
    ):
        cellranger.main(name="cellranger", version="10.0.0", prefix=prefix)

    assert extract_mock.call_count == 2
    assert (Path(prefix) / "bin").is_symlink()


def test_fix_unibilium_soname_creates_symlink(tmp_path: Path) -> None:
    """The malformed soname is symlinked to the real, correctly-built library."""
    lib_dir = tmp_path / "libexec" / "lib"
    lib_dir.mkdir(parents=True)
    (lib_dir / "libunibilium.so.4.0.2").touch()
    (lib_dir / "libunibilium.so.4").symlink_to("libunibilium.so.4.0.2")

    neovim._fix_unibilium_soname(str(tmp_path / "libexec"))

    broken = lib_dir / "libunibilium.so.."
    assert broken.is_symlink()
    assert os.readlink(broken) == "libunibilium.so.4.0.2"


def test_fix_unibilium_soname_is_idempotent(tmp_path: Path) -> None:
    """A second run does not touch an already-repaired lib dir."""
    lib_dir = tmp_path / "libexec" / "lib"
    lib_dir.mkdir(parents=True)
    (lib_dir / "libunibilium.so.4.0.2").touch()
    broken = lib_dir / "libunibilium.so.."
    broken.symlink_to("some-other-target")

    neovim._fix_unibilium_soname(str(tmp_path / "libexec"))

    assert os.readlink(broken) == "some-other-target"


def test_fix_unibilium_soname_noop_when_library_absent(tmp_path: Path) -> None:
    """No unibilium library present means nothing to link against; skip silently."""
    lib_dir = tmp_path / "libexec" / "lib"
    lib_dir.mkdir(parents=True)

    neovim._fix_unibilium_soname(str(tmp_path / "libexec"))

    assert not (lib_dir / "libunibilium.so..").exists()


def test_neovim_main_applies_fix_on_linux() -> None:
    """main() wires the unibilium hotfix into install_conda_package on Linux."""
    with (
        patch("koopa.installers.neovim.is_linux", return_value=True),
        patch("koopa.installers.neovim.install_conda_package") as install_mock,
    ):
        neovim.main(name="neovim", version="0.12.5", prefix="/opt/koopa/app/neovim/0.12.5")

    assert install_mock.call_args.kwargs["post_extract_fn"] is neovim._fix_unibilium_soname


def test_neovim_main_skips_fix_off_linux() -> None:
    """main() does not install the hotfix on a platform ldd can't help with."""
    with (
        patch("koopa.installers.neovim.is_linux", return_value=False),
        patch("koopa.installers.neovim.install_conda_package") as install_mock,
    ):
        neovim.main(name="neovim", version="0.12.5", prefix="/opt/koopa/app/neovim/0.12.5")

    assert install_mock.call_args.kwargs["post_extract_fn"] is None
