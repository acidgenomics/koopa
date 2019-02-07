#!/usr/bin/env bash
set -Eeuo pipefail

# Install TeX (BasicTeX)
# https://www.ctan.org
# This will also attempt to install recommended packages.

echo "This script requires sudo to install"
sudo -v

# Attempt to install basictex automatically.
# This contains tlmgr, which manages CTAN packages.
command -v tlmgr >/dev/null 2>&1 || {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "Installing basictex cask"
        command -v brew >/dev/null 2>&1 || {
            echo >&2 "brew missing"
            exit 1
        }
        brew cask install basictex
    fi
}

# Check for tlmgr again and error if not installed.
command -v tlmgr >/dev/null 2>&1 || {
    echo >&2 "tlmgr missing"
    exit 1
}
