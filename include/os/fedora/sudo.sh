#!/usr/bin/env bash
set -Eeuo pipefail

# Source bash functions.
# shellcheck source=/dev/null
source "${KOOPA_DIR}/include/shell/bash/functions.sh"

if ! has_sudo
then
    echo "Non-interactive (passwordless) sudo is required for this script."
    exit 1
fi

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
    >&2 echo "Error: yum is required to build dependencies."
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

# Ensure yum-utils is installed, so we can build dependencies.
# > sudo -n yum -y install yum-utils

# Install gcc, if necessary.
if [[ ! -x "$(command -v gcc)" ]]
then
    sudo -n yum install -y gcc
fi

# Ensure ldconfig is configured to use /usr/local.
if [[ -d /etc/ld.so.conf.d ]]
then
    sudo -n cp "${KOOPA_DIR}/config/os/fedora/etc/ld.so.conf.d/"*".conf" \
        /etc/ld.so.conf.d
fi

# Ensure /usr/local has correct permissions.
sudo -n chown -Rh "root:wheel" /usr/local
sudo -n chmod g+w /usr/local
