#!/usr/bin/env bash
set -Eeuxo pipefail

# GNU Scientific Library (GSL)
# https://www.gnu.org/software/gsl/
# Required for some single-cell RNA-seq R packages.

build_dir="/tmp/gsl"
prefix="/usr/local"
version="2.5"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

echo "Installing GSL ${version}."
echo "sudo is required for this script."
sudo -v

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "http://mirror.keystealth.org/gnu/gsl/gsl-${version}.tar.gz"
    tar xzvf "gsl-${version}.tar.gz"
    cd "gsl-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    make check
    sudo make install
)

# Ensure ldconfig is current.
sudo ldconfig

echo "gsl installed successfully."

unset -v build_dir prefix version
