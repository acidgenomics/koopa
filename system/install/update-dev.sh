#!/usr/bin/env bash
set -Eeu -o pipefail

# Update submodules.
# Modified 2019-06-21.

(
    # shellcheck source=/dev/null
    cd "$KOOPA_HOME"
    git fetch --all
    git pull
    git submodule update --init --recursive
    git submodule foreach -q --recursive git checkout master
    git submodule foreach -q --recursive git pull
    git submodule status
    git status
)
