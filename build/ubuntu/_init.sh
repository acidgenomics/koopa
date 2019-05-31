#!/usr/bin/env bash
set -Eeuxo pipefail

echo "sudo access is required for installation."
sudo -v

# Check for RedHat.
if ! grep -q "ID=ubuntu" /etc/os-release
then
    echo "Error: Ubuntu Linux is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

# Require apt-get to build dependencies.
if [[ ! -x "$(command -v apt-get)" ]]
then
    echo "Error: apt-get is required to build dependencies." >&2
    exit 1
fi

# Ensure apt-get is up to date.
sudo apt-get -y update
