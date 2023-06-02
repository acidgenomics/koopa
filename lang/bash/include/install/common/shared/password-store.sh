#!/usr/bin/env bash

main() {
    # """
    # Install Password Store.
    # @note Updated 2023-06-01.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://git.zx2c4.com/password-store/snapshot/\
password-store-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    PREFIX="${dict['prefix']}" "${app['make']}" install
    return 0
}
