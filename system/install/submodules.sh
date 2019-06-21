#!/usr/bin/env bash
set -Eeu -o pipefail

# Initialize submodules.
# Modified 2019-06-21.

# Currently only necessary when dot files are enabled.

(
    printf "\nInitializing submodules.\n"
    # shellcheck source=/dev/null
    cd "$KOOPA_DIR"
    git submodule init
    git submodule update --init --recursive
    git submodule sync --recursive
    # Change remote from HTTPS to git for easier commits.
    if [[ -n "${devel:-}" ]]
    then
        git remote set-url origin git@github.com:acidgenomics/koopa.git
    fi
)

(
    printf "\nInitializing dotfiles submodules.\n"
    # shellcheck source=/dev/null
    cd "${KOOPA_DIR}/system/config/dotfiles"
    git submodule init
    git submodule update --init --recursive
    git submodule sync --recursive
    # Change remote from HTTPS to git for easier commits.
    if [[ -n "${devel:-}" ]]
    then
        git remote set-url origin git@github.com:mjsteinbaugh/dotfiles.git
    fi
)
