#!/usr/bin/env bash

main() {
    # """
    # Install Spacemacs.
    # @note Updated 2022-09-16.
    #
    # Installation is not entirely non-interactive, and currently asks to
    # compile vterm. Not sure how to improve this.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['yes']="$(koopa_locate_yes --allow-system)"
    )
    [[ -x "${app['yes']}" ]] || return 1
    koopa_activate_app --build-only 'chemacs'
    declare -A dict=(
        ['commit']="${KOOPA_INSTALL_VERSION:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url']='https://github.com/syl20bnr/spacemacs.git'
    )
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    "${app['yes']}" | koopa_spacemacs --no-window-system
    return 0
}
