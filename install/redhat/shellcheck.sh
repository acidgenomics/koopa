#!/usr/bin/env bash
set -Eeuxo pipefail

# ShellCheck EPEL v0.3.5
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

echo "Installing EPEL release."
sudo yum -y install epel-release

echo "Installing old EPEL of ShellCheck."
sudo yum install -y ShellCheck

echo "shellcheck installed successfully."
command -v shellcheck
shellcheck --version
