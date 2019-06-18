#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/include/shell/bash/functions.sh"

if ! has_sudo
then
    >&2 printf "Error: sudo is required for this script.\n"
    exit 1
fi

# Check for Fedora.
if ! grep "ID="      /etc/os-release | grep -q "fedora" &&
   ! grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
then
    >&2 printf "Error: Fedora is required.\n"
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    >&2 printf "Error: yum is required to build dependencies.\n"
    exit 1
fi

# Ensure conda is deactivated.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    >&2 printf "Error: conda is active.\n"
    exit 1
fi

# Ensure Python virtual environment is deactivated.
if [[ -x "$(command -v deactivate)" ]]
then
    >&2 printf "Error: Python virtualenv is active.\n"
    exit 1
fi

# Ensure yum-utils is installed, so we can build dependencies.
# > sudo yum -y install yum-utils

# Install gcc, if necessary.
if [[ ! -x "$(command -v gcc)" ]]
then
    sudo yum install -y gcc
fi

# Ensure ldconfig is configured to use /usr/local.
if [[ -d /etc/ld.so.conf.d ]]
then
    sudo cp "${KOOPA_DIR}/config/etc/ld.so.conf.d/"*".conf" \
        /etc/ld.so.conf.d
fi

# Ensure /usr/local has correct permissions.
sudo chown -Rh "root:wheel" /usr/local
sudo chmod g+w /usr/local
