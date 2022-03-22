#!/usr/bin/env bash

install_chemacs() { # {{{1
    # """
    # Install Chemacs2.
    # @note Updated 2022-02-02.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/plexus/chemacs2'
    )
    koopa_git_clone "${dict[url]}" "${dict[prefix]}"
    koopa_configure_chemacs
    return 0
}
