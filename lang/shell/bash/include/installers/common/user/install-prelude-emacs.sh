#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Prelude Emacs.
    # @note Updated 2021-11-23.
    #
    # @seealso
    # - https://prelude.emacsredux.com/en/latest/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/bbatsov/prelude.git'
    )
    koopa_git_clone "${dict[url]}" "${dict[prefix]}"
    return 0
}
