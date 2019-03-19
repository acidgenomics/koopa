#!/usr/bin/env bash
set -Eeuxo pipefail

# Git SCM
# See also:
# - https://github.com/git/git
# - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
# - https://github.com/git/git/blob/master/INSTALL
# - https://github.com/progit/progit2/blob/master/book/01-introduction/sections/installing.asc

# Error on conda detection.
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

sudo -v

# Install build dependencies, if necessary.
if [ -x "$(command -v yum)" ]
then
    sudo yum -y install yum-utils
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
    sudo ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
fi

PREFIX="/usr/local"
VERSION="2.20.1"

wget "https://github.com/git/git/archive/v${VERSION}.tar.gz"
tar -zxf "v${VERSION}.tar.gz"
cd "git-${VERSION}" || return 1

# The compilation settings here are from the Git SCM book website.

make configure
./configure --prefix="$PREFIX"
make all doc info
sudo make install install-doc install-html install-info

git --version
