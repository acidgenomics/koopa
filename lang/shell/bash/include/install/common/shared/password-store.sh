#!/usr/bin/env bash

main() {
    # """
    # Install Password Store.
    # @note Updated 2022-07-18.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='password-store'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://git.zx2c4.com/${dict['name']}/snapshot/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    PREFIX="${dict['prefix']}" "${app['make']}" install
    return 0
}
