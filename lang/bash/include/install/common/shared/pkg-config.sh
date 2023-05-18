#!/usr/bin/env bash

main() {
    # """
    # Install pkg-config.
    # @note Updated 2023-04-10.
    #
    # Requires cmp and diff to be installed.
    #
    # Alternate mirror that is less reliable:
    # https://pkg-config.freedesktop.org/releases/
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local -A dict
    local -a conf_args
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
        '--disable-debug'
        '--disable-host-tool'
        "--prefix=${dict['prefix']}"
        '--with-internal-glib'
        "--with-system-include-path=${dict['sys_inc']}"
    )
    if koopa_is_macos
    then
        dict['pc_path']='/usr/lib/pkgconfig'
        conf_args+=("--with-pc-path=${dict['pc_path']}")
    fi
    dict['url']="http://fresh-center.net/linux/misc/\
pkg-config-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
