#!/usr/bin/env bash

koopa::install_r_cmd_check() { # {{{1
    koopa::install_app \
        --name='r-cmd-check' \
        "$@"
}

koopa:::install_r_cmd_check() { # {{{1
    # """
    # Install R CMD check (Rcheck) scripts for CI.
    # @note Updated 2021-06-02.
    # """
    local prefix source_repo
    prefix="${INSTALL_PREFIX:?}"
    source_repo='https://github.com/acidgenomics/r-cmd-check.git'
    koopa::mkdir "$prefix"
    koopa::git_clone "$source_repo" "$prefix"
    return 0
}

# FIXME Need to include an updater.
