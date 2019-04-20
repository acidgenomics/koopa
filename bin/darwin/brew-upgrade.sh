#!/usr/bin/env bash
set -Eeuxo pipefail

# Consider requiring admin account.
# if [[ "$(whoami)" != "admin" ]]; then
#     echo "This script must be run as admin"
#     exit 1
# fi

# Homebrew
brew update

echo "Upgrading Homebrew..."
brew upgrade --force-bottle
# brew list | xargs brew reinstall --force-bottle --cleanup

echo "Upgrading Homebrew Casks..."
brew cask outdated | xargs brew cask reinstall

# Mac App Store
if [[ -x "$(command -v mas)" ]]
then
    echo "Upgrading Mac App Store Apps..."
    mas upgrade
fi
