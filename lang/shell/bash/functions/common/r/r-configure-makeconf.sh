#!/usr/bin/env bash

koopa_r_configure_makeconf() {
    # """
    # Modify the 'Makeconf' file to ensure correct configuration.
    # @note Updated 2022-08-30.
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
        ['pcre2']="$(koopa_app_prefix 'pcre2')"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    )
    dict['file']="${dict['r_prefix']}/etc/Makeconf"
    koopa_assert_is_dir \
        "${dict['pcre2']}" \
        "${dict['r_prefix']}"
    koopa_alert "Updating ${dict['file']}"
    koopa_assert_is_admin
    koopa_assert_is_file "${dict['file']}"
    koopa_add_to_pkg_config_path \
        "${dict['pcre2']}/lib/pkgconfig"
    libs=(
        "$("${app['pkg_config']}" --libs 'libpcre2-8')"
        '-llzma'
        '-lbz2'
        '-lz'
        '-licucore'
        '-ldl'
        '-lm'
        '-liconv'
    )
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
