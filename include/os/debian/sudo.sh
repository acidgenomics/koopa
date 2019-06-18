#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/include/shell/bash/functions.sh"

if ! has_sudo
then
    >&2 printf "Error: sudo is required for this script.\n"
    exit 1
fi

# Check for RedHat.
if ! grep -q "ID=ubuntu" /etc/os-release
then
    >&2 printf "Error: Ubuntu Linux is required.\n"
    exit 1
fi

# Require apt-get to build dependencies.
if [[ ! -x "$(command -v apt-get)" ]]
then
    >&2 printf "Error: apt-get is required to build dependencies.\n"
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

# Ensure apt-get is up to date.
sudo apt-get -y update

# Ensure /usr/local has correct permissions.
sudo chown -Rh "root:sudo" /usr/local
sudo chmod g+w /usr/local
