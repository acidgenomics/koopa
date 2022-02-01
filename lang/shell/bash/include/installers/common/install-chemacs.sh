#!/usr/bin/env bash

koopa:::install_chemacs() { # {{{1
    # """
    # Install Chemacs2.
    # @note Updated 2022-02-01.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/plexus/chemacs2'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    koopa::configure_chemacs
    return 0
}
