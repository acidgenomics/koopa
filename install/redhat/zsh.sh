#!/usr/bin/env bash
set -Eeuxo pipefail

# Z shell
#
# See also:
# - http://www.zsh.org/
# - http://zsh.sourceforge.net/Arc/source.html
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH

build_dir="/tmp/build/zsh"
prefix="/usr/local"
version="5.7.1"

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

echo "Installing zsh ${version}."
echo "sudo is required for this script."
sudo -v

sudo yum install -y zsh
sudo yum install -y yum-utils
sudo yum-builddep -y zsh

(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"
    wget https://sourceforge.net/projects/zsh/files/zsh/${version}/zsh-${version}.tar.xz/download
    tar -xJvf "download"
    cd "zsh-${version}"
    ./configure --build="x86_64-redhat-linux-gnu" --prefix="$prefix"
    make
    make check
    # make test
    sudo make install
    rm -rf "$build_dir"
)

# Consider adding a check in /etc/shells.
# grep "${prefix}/bin/zsh" /etc/shells
# And then if there's no match, append the file automatically.

echo "Updating default shell."
chsh -s /usr/local/bin/zsh

cat << EOF
zsh installed successfully.
Reload the shell and check version.
command -v zsh
zsh --version
EOF
