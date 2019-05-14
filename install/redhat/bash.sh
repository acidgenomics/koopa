#!/usr/bin/env bash
set -Eeuxo pipefail

# Bash
# https://www.gnu.org/software/bash/

build_dir="/tmp/build/bash"
prefix="/usr/local"
version="5.0"

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

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
    exit 1
fi

echo "Installing bash ${version}."
echo "sudo is required for this script."
sudo -v

sudo yum install -y yum-utils
sudo yum-builddep -y bash

(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"
    wget http://ftpmirror.gnu.org/bash/bash-${version}.tar.gz
    tar -xzvf "bash-${version}.tar.gz"
    cd "bash-${version}"
    ./configure --build="x86_64-redhat-linux-gnu" --prefix="$prefix"
    make
    make test
    sudo make install
    rm -rf "$build_dir"
)

# Consider adding a check in /etc/shells.
# grep "${prefix}/bin/bash" /etc/shells
# And then if there's no match, append the file automatically.

echo "Updating default shell."
chsh -s /usr/local/bin/bash

echo "Reloading the shell."
exec bash

echo "bash installed successfully."

command -v bash
bash --version
