#!/usr/bin/env bash

main() {
    # """
    # Install Luarocks.
    # @note Updated 2022-09-10.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'unzip'
    koopa_activate_app 'lua'
    declare -A app=(
        ['lua']="$(koopa_locate_lua)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['lua']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='luarocks'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['lua_version']="$(koopa_get_version "${app['lua']}")"
    dict['lua_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['lua_version']}" \
    )"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://luarocks.org/releases/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        "--lua-version=${dict['lua_maj_min_ver']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" build
    "${app['make']}" install
    return 0
}
