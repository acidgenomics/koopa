#!/usr/bin/env bash

main() {
    # """
    # Install pkg-config.
    # @note Updated 2023-04-06.
    #
    # Requires cmp and diff to be installed.
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        dict['sys_inc']="${dict['sdk_prefix']}/usr/include"
    else
        dict['sys_inc']='/usr/include'
    fi
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
    # Alternate mirror that is less reliable:
    # https://pkg-config.freedesktop.org/releases/
    dict['url']="http://fresh-center.net/linux/misc/\
pkg-config-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
