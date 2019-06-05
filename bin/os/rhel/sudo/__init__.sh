#!/usr/bin/env bash
set -Eeuo pipefail

echo "sudo access is required for installation."

# This check doesn't work for passwordless sudo (e.g. ec2-user), so disable.
# sudo -v

# Check for RedHat.
if ! grep -q 'ID="rhel"' /etc/os-release &&
   ! grep -q 'ID_LIKE="centos rhel fedora"' /etc/os-release
then
    echo "Error: RedHat Enterprise Linux (RHEL) is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]] &&
   [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
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
if [[ ! -f /etc/ld.so.conf.d ]]
then
    sudo cp "${KOOPA_BASE_DIR}/etc/ld.so.conf.d/local"*".conf" /etc/ld.so.conf.d
fi
