#!/usr/bin/env bash
set -Eeuxo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

git submodule init
git submodule update

# dotfiles
(
    cd dotfiles
    git submodule init
    git submodule update
)

. "${script_dir}/UPDATE.sh"
