#!/usr/bin/env bash

main() {
    # """
    # Install pkg-config.
    # @note Updated 2024-09-04.
    #
    # Requires cmp and diff to be installed.
    #
    # Alternate mirror that is less reliable:
    # https://pkg-config.freedesktop.org/releases/
    #
    # Return PKG_CONFIG_PATH with:
    # pkg-config --variable pc_path pkg-config
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
        if [[ -d "/usr/lib/${dict['arch']}-linux-gnu/pkgconfig" ]]
        then
            pc_path+=("/usr/lib/${dict['arch']}-linux-gnu/pkgconfig")
        fi
        if [[ -d '/usr/lib64/pkgconfig' ]]
        then
            pc_path+=('/usr/lib64/pkgconfig')
        fi
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
        # Workaround for build issue with Xcode 15.3.
        # https://gitlab.freedesktop.org/pkg-config/pkg-config/-/issues/81
        koopa_append_cflags '-Wno-int-conversion'
    fi
    koopa_assert_is_dir "${dict['sys_inc']}"
    conf_args+=(
        '--disable-debug'
        '--disable-host-tool'
        "--prefix=${dict['prefix']}"
        '--with-internal-glib'
        "--with-system-include-path=${dict['sys_inc']}"
    )
    if koopa_is_array_non_empty "${pc_path[@]}"
    then
        koopa_assert_is_dir "${pc_path[@]}"
        dict['pc_path']="$(koopa_paste --sep=':' "${pc_path[@]}")"
        conf_args+=("--with-pc-path=${dict['pc_path']}")
    fi
    dict['url']="https://pkgconfig.freedesktop.org/releases/\
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
