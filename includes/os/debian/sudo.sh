#!/usr/bin/env bash
set -Eeuo pipefail

echo "sudo access is required for installation."

# This check doesn't work for passwordless sudo on all VMs.
# sudo -v

# Check for RedHat.
if ! grep -q "ID=ubuntu" /etc/os-release
then
    echo "Error: Ubuntu Linux is required." >&2
    exit 1
fi

# Require apt-get to build dependencies.
if [[ ! -x "$(command -v apt-get)" ]]
then
    echo "Error: apt-get is required to build dependencies." >&2
    exit 1
fi

# Ensure conda is deactivated.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active."
    exit 1
fi

# Ensure Python virtual environment is deactivated.
if [[ -x "$(command -v deactivate)" ]]
then
    echo "Error: Python virtualenv is active."
    exit 1
fi

# Ensure apt-get is up to date.
sudo apt-get -y update

# Ensure /usr/local has correct permissions.
sudo chown -R "root:sudo" /usr/local
sudo chmod g+w /usr/local
