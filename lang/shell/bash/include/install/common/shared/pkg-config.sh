#!/usr/bin/env bash

main() {
    # """
    # Install pkg-config.
    # @note Updated 2023-03-26.
    #
    # Requires cmp and diff to be installed.
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='pkg-config'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
# >     dict['url']="https://${dict['name']}.freedesktop.org/releases/\
# > ${dict['file']}"
    dict['url']="http://fresh-center.net/linux/misc/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['sys_inc']='/usr/include'
    if koopa_is_macos
    then
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        dict['sys_inc']="${dict['sdk_prefix']}/${dict['sys_inc']}"
    fi
    koopa_assert_is_dir "${dict['sys_inc']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-host-tool'
        '--with-internal-glib'
        "--with-system-include-path=${dict['sys_inc']}"
    )
    if koopa_is_macos
    then
        dict['pc_path']='/usr/lib/pkgconfig'
        conf_args+=("--with-pc-path=${dict['pc_path']}")
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
