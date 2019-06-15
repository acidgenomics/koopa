#!/usr/bin/env bash
set -Eeuo pipefail

# Update submodules.
# Modified 2019-06-12.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

(
    cd "$script_dir"
    git fetch --all
    git pull
    git submodule update --init --recursive
    git submodule foreach -q --recursive git checkout master
    git submodule foreach -q --recursive git pull
    git submodule status
    git status
)
