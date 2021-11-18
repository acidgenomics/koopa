#!/usr/bin/env bash

koopa:::install_chemacs() { # {{{1
    # """
    # Install Chemacs2.
    # @note Updated 2021-11-18.
    # """
    local dict
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/plexus/chemacs2'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    return 0
}
