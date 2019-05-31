#!/usr/bin/env bash
set -Eeuxo pipefail

# Update submodules

git fetch --all
git pull
git submodule sync --recursive
git submodule update --init --recursive
git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
git submodule foreach git pull
git submodule status
git status
