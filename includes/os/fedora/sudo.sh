#!/usr/bin/env bash
set -Eeuo pipefail

echo "sudo access is required for installation."

# This check doesn't work for passwordless sudo on all VMs.
# sudo -v

# Check for Fedora.
if ! grep "ID="      /etc/os-release | grep -q "fedora" &&
   ! grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
then
    echo "Error: Fedora is required." >&2
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
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

# Ensure yum-utils is installed, so we can build dependencies.
sudo yum -y install yum-utils

# Install gcc, if necessary.
if [[ ! -x "$(command -v gcc)" ]]
then
    sudo yum install -y gcc
fi

# Ensure ldconfig is configured to use /usr/local.
if [[ -d /etc/ld.so.conf.d ]]
then
    sudo cp "${KOOPA_BASE_DIR}/includes/os/fedora/etc/ld.so.conf.d/"*".conf" \
        /etc/ld.so.conf.d
fi

# Ensure /usr/local has correct permissions.
sudo chown -R "root:wheel" /usr/local
sudo chmod g+w /usr/local
