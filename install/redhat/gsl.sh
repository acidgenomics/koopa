#!/usr/bin/env bash
set -Eeuxo pipefail

# GNU Scientific Library (GSL)
# https://www.gnu.org/software/gsl/
# Required for some single-cell RNA-seq R packages.

build_dir="/tmp/build/gsl"
prefix="/usr/local"
version="2.5"

echo "Installing GSL ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "$script_dir/_init.sh"

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "http://mirror.keystealth.org/gnu/gsl/gsl-${version}.tar.gz"
    tar xzvf "gsl-${version}.tar.gz"
    cd "gsl-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    make check
    sudo make install
    rm -rf "$build_dir"
)

# Ensure ldconfig is current.
sudo ldconfig

echo "gsl installed successfully."
command -v gsl-config
gsl-config --version
