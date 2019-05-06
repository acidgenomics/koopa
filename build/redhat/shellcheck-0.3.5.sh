#!/usr/bin/env bash
set -Eeuxo pipefail

# ShellCheck
# v0.6.0 needs dependencies installed from source.
#
# See also:
# - Install ShellCheck from source
#   https://github.com/koalaman/shellcheck#compiling-from-source
# - Install GHC and cabal-install from source
#   https://www.haskell.org/downloads/linux/

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
    exit 1
fi

echo "Installing older version of ShellCheck for all users."
sudo yum install -y ShellCheck

# echo "Installing newest version of ShellCheck for ${USER}."
# Note that this will install into `$HOME` instead of `/usr/local`.

# ShellCheck is built and packaged using Cabal.
# sudo yum install -y cabal-install

# Ensure cabal is installed and up to date.
# cabal update

# This will install to `~/.cabal/bin/shellcheck`.
# cabal install ShellCheck

echo "shellcheck installed successfully."
command -v shellcheck
shellcheck --version
