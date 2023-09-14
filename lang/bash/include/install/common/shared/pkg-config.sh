#!/usr/bin/env bash

main() {
    # """
    # Install pkg-config.
    # @note Updated 2023-09-14.
    #
    # Requires cmp and diff to be installed.
    #
    # Alternate mirror that is less reliable:
    # https://pkg-config.freedesktop.org/releases/
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # - https://formulae.brew.sh/formula/pkg-config
    # """
    local -A app dict
    local -a conf_args pc_path
    dict['arch']="$(koopa_arch)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_linux
    then
        dict['sys_inc']='/usr/include'
        pc_path+=("/usr/lib/${dict['arch']}-linux-gnu/pkgconfig")
        if [[ -d '/usr/lib/pkgconfig' ]]
        then
            pc_path+=('/usr/lib/pkgconfig')
        fi
        if [[ -d '/usr/share/pkgconfig' ]]
        then
            pc_path+=('/usr/share/pkgconfig')
        fi
    elif koopa_is_macos
    then
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        dict['sys_inc']="${dict['sdk_prefix']}/usr/include"
        pc_path+=('/usr/lib/pkgconfig')
    fi
    koopa_assert_is_dir "${dict['sys_inc']}" "${pc_path[@]}"
    dict['pc_path']="$(koopa_paste --sep=':' "${pc_path[@]}")"
    conf_args=(
        '--disable-debug'
        '--disable-host-tool'
        "--prefix=${dict['prefix']}"
        '--with-internal-glib'
        "--with-pc-path=${dict['pc_path']}"
        "--with-system-include-path=${dict['sys_inc']}"
    )
    dict['url']="http://fresh-center.net/linux/misc/\
pkg-config-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    app['pkg_config']="${dict['prefix']}/bin/pkg-config"
    koopa_assert_is_executable "${app['pkg_config']}"
    "${app['pkg_config']}" --variable 'pc_path' 'pkg-config'
    return 0
}
