#!/usr/bin/env bash
set -Eeuxo pipefail

brew cleanup -s
brew cask cleanup
brew prune
