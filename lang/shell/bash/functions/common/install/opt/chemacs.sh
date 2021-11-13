#!/usr/bin/env bash

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

koopa:::update_chemacs() { # {{{1
    # """
    # Update Chemacs2.
    # @note Updated 2021-09-17.
    # """
    local prefix
    prefix="${UPDATE_PREFIX:?}"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    return 0
}
