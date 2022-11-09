#!/usr/bin/env bash

main() {
    # """
    # Install Spacemacs.
    # @note Updated 2022-11-09.
    #
    # Installation is not entirely non-interactive, and currently asks to
    # compile vterm. Not sure how to improve this.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['commit']="${KOOPA_INSTALL_VERSION:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url']='https://github.com/syl20bnr/spacemacs.git'
    )
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    return 0
}
