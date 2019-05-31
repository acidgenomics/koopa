#!/usr/bin/env bash
set -Eeuxo pipefail

# Git SCM
# https://git-scm.com/
#
# See also:
# - https://github.com/git/git
# - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
# - https://github.com/git/git/blob/master/INSTALL
# - https://github.com/progit/progit2/blob/master/book/01-introduction/sections/installing.asc

build_dir="/tmp/build/git"
prefix="/usr/local"
version="2.21.0"

echo "Installing git ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=/dev/null
. "${script_dir}/_init.sh"

# Install build dependencies.
sudo yum-builddep -y git

# This is required for git to make doc cleanly.
#
# Otherwise, you'll see this error:
# /bin/sh: line 1: docbook2x-texi: command not found
#
# This issue is reference here:
# https://github.com/progit/progit2/issues/425
#
# Note the capital "X" here. This differs depending on the Linux distro.
# We're assuming Red Hat here.
sudo yum install docbook2X

# This step is required to fix a binary name difference.
if [[ ! -f /usr/bin/docbook2x-texi ]]
then
    sudo ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
fi

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://github.com/git/git/archive/v${version}.tar.gz"
    tar -zxf "v${version}.tar.gz"
    cd "git-${version}" || return 1
    # The compilation settings here are from the Git SCM book website.
    make configure
    ./configure --prefix="$prefix"
    make all doc info
    sudo make install install-doc install-html install-info
    rm -rf "$build_dir"
)

# Ensure ldconfig is current.
sudo ldconfig

echo "git installed successfully."
command -v git
git --version
