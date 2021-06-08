#!/usr/bin/env bash

koopa::install_chemacs() { # {{{1
    koopa::install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
    return 0
}

koopa:::install_chemacs() { # {{{1
    # """
    # Install Chemacs2.
    # @note Updated 2021-06-07.
    # """
    local prefix repo
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/plexus/chemacs2'
    koopa::git_clone "$repo" "$prefix"
    return 0
}

# FIXME Add updater.

# FIXME Add uninstaller.
