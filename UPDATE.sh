#!/usr/bin/env bash
set -Eeuxo pipefail

# Update submodules

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

(
    cd "$script_dir"
    git fetch --all
    git pull
    git submodule sync --recursive
    git submodule update --init --recursive
    git submodule foreach -q --recursive git checkout master
    git submodule foreach git pull
    git submodule status
    git status
)


