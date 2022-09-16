#!/usr/bin/env bash

main() {
    # """
    # Install Spacemacs.
    # @note Updated 2022-09-16.
    #
    # Installation is not entirely non-interactive, and currently asks to
    # compile vterm. Not sure how to improve this.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'chemacs'
    declare -A dict=(
        ['commit']="${KOOPA_INSTALL_VERSION:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url']='https://github.com/syl20bnr/spacemacs.git'
    )
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    koopa_spacemacs --no-window-system
    return 0
}
