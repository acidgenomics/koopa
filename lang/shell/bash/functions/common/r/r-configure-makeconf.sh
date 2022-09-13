#!/usr/bin/env bash

# FIXME Need to describe the LIBS flags in use here.
# - * '-ldl'
# - * '-lm'
# - * '-lrt' (Linux)
# - * '-ltirpc' (Linux)

koopa_r_configure_makeconf() {
    # """
    # Modify the 'Makeconf' file to ensure correct configuration.
    # @note Updated 2022-09-12.
    #
    # Default LIBS:
    # - macOS: -lpcre2-8 -llzma -lbz2 -lz -licucore -ldl -lm -liconv
    # - Ubuntu: -lpcre2-8 -llzma -lbz2 -lz -ltirpc -lrt -ldl
    #     -lm -licuuc -licui18n
    #
    # @seealso
    # - /opt/koopa/opt/r/lib/R/etc/Makeconf
    # - /Library/Frameworks/R.framework/Versions/Current/Resources/etc/Makeconf
    # """
    local app dict libs
    declare -A app
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    koopa_is_koopa_app "${app['r']}" && return 0
    app['pkg_config']="$(koopa_locate_pkg_config)"
    [[ -x "${app['pkg_config']}" ]] || return 1
    declare -A dict=(
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['icu4c']="$(koopa_app_prefix 'icu4c')"
        ['libiconv']="$(koopa_app_prefix 'libiconv')"
        ['pcre2']="$(koopa_app_prefix 'pcre2')"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    dict['file']="${dict['r_prefix']}/etc/Makeconf"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['icu4c']}" \
        "${dict['libiconv']}" \
        "${dict['pcre2']}" \
        "${dict['r_prefix']}" \
        "${dict['zlib']}"
    koopa_alert "Updating ${dict['file']}"
    koopa_assert_is_admin
    koopa_assert_is_file "${dict['file']}"
    koopa_add_to_pkg_config_path \
        "${dict['icu4c']}/lib/pkgconfig" \
        "${dict['pcre2']}/lib/pkgconfig" \
        "${dict['zlib']}/lib/pkgconfig"
    libs=(
        "$("${app['pkg_config']}" --libs \
            'libpcre2-8' \
            'icu-i18n' \
            'icu-uc' \
            'zlib' \
        )"
        "-L${dict['bzip2']}/lib"
        "-L${dict['libiconv']}/lib"
        '-ldl'
        '-lm'
    )
    if koopa_is_linux
    then
        libs+=('-ltirpc' '-lrt')
    fi
    dict['pattern']='^LIBS = .+$'
    dict['replacement']="LIBS = ${libs[*]}"
    koopa_find_and_replace_in_file \
        --sudo \
        --pattern="${dict['pattern']}" \
        --replacement="${dict['replacement']}" \
        --regex \
        "${dict['file']}"
    unset -v PKG_CONFIG_PATH
    return 0
}
