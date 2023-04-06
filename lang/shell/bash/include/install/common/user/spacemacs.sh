#!/usr/bin/env bash

main() {
    # """
    # Install Spacemacs.
    # @note Updated 2023-04-06.
    #
    # Installation is not entirely non-interactive, and currently asks to
    # compile vterm. Not sure how to improve this.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://github.com/syl20bnr/spacemacs.git'
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    return 0
}
