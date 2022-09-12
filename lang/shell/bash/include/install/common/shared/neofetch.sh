#!/usr/bin/env bash

main() {
    # """
    # Install neofetch.
    # @note Updated 2021-12-14.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='neofetch'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/dylanaraps/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir "${dict['prefix']}"
    koopa_print_env
    "${app['make']}" PREFIX="${dict['prefix']}" install
    return 0
}
