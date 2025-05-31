#!/usr/bin/env bash

main() {
    # """
    # Install pkgconf.
    # @note Updated 2025-05-31.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/pkgconf
    # - https://github.com/pkgconf/pkgconf
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
    fi
    koopa_assert_is_dir "${dict['sys_inc']}"
    conf_args+=(
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        "--with-system-includedir=${dict['sys_inc']}"
        '--with-system-libdir=/usr/lib'
    )
    if koopa_is_array_non_empty "${pc_path[@]:-}"
    then
        koopa_assert_is_dir "${pc_path[@]}"
        dict['pc_path']="$(koopa_paste --sep=':' "${pc_path[@]}")"
        conf_args+=("--with-pkg-config-dir=${dict['pc_path']}")
    fi
    dict['url']="https://distfiles.ariadne.space/pkgconf/\
pkgconf-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    app['pkgconf']="${dict['prefix']}/bin/pkgconf"
    koopa_assert_is_executable "${app['pkgconf']}"
    "${app['pkgconf']}" --variable 'pc_path' 'pkg-config'
    return 0
}
