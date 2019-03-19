#!/usr/bin/env bash
set -Eeuxo pipefail

# Install shellcheck from source
# https://github.com/koalaman/shellcheck#compiling-from-source



echo "Installing older version of ShellCheck for all users."
sudo yum install -y ShellCheck



echo "Installing newest version of ShellCheck for ${USER}."
# Note that this will install into `$HOME` instead of `/usr/local`.

# ShellCheck is built and packaged using Cabal.
sudo yum install -y cabal-install

# Ensure cabal is installed and up to date.
cabal update

# This will install to `~/.cabal/bin/shellcheck`.
cabal install ShellCheck



which shellcheck
shellcheck --version
