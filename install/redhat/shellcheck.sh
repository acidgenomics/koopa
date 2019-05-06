#!/usr/bin/env bash
set -Eeuxo pipefail

# ShellCheck
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

# Note that EPEL version is super old and many current checks don't work.
echo "Installing old EPEL version of ShellCheck to /usr/bin."
sudo yum -y install epel-release
sudo yum install -y ShellCheck

version="v0.6.0"
echo "Copying newer ${version} binary version to /usr/local/bin."
wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-"${version}".linux.x86_64.tar.xz" | \
    tar -xJv
sudo cp shellcheck-"${version}"/shellcheck /usr/local/bin/

echo "shellcheck installed successfully."
command -v shellcheck
shellcheck --version
