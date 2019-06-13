#!/usr/bin/env bash
set -Eeuo pipefail

echo "sudo access is required for installation."

# This check doesn't work for passwordless sudo on all VMs.
# sudo -v

# Check for RedHat.
if ! grep -q "ID=ubuntu" /etc/os-release
then
    >&2 echo "Error: Ubuntu Linux is required."
    exit 1
fi

# Require apt-get to build dependencies.
if [[ ! -x "$(command -v apt-get)" ]]
then
    >&2 echo "Error: apt-get is required to build dependencies."
    exit 1
fi

# Ensure conda is deactivated.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    >&2 echo "Error: conda is active."
    exit 1
fi

# Ensure Python virtual environment is deactivated.
if [[ -x "$(command -v deactivate)" ]]
then
    >&2 echo "Error: Python virtualenv is active."
    exit 1
fi

# Ensure apt-get is up to date.
sudo apt-get -y update

# Ensure /usr/local has correct permissions.
sudo chown -Rh "root:sudo" /usr/local
sudo chmod g+w /usr/local
