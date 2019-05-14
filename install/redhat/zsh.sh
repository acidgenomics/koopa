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

echo "Installing zsh ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "$script_dir/_init.sh"

# Install build dependencies.
sudo yum install -y zsh
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
