#!/usr/bin/env bash

main() {
    # """
    # Install Prelude Emacs.
    # @note Updated 2022-07-14.
    #
    # @seealso
    # - https://prelude.emacsredux.com/en/latest/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [commit]="${INSTALL_VERSION:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/bbatsov/prelude.git'
    )
    koopa_git_clone \
        --commit="${dict[commit]}" \
        --prefix="${dict[prefix]}" \
        --url="${dict[url]}"
    return 0
}
