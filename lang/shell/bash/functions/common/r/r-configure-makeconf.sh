#!/usr/bin/env bash

# Need to describe the LIBS flags in use here.
# - * '-ldl'
# - * '-lm'
# - * '-lrt' (Linux)
# - * '-ltirpc' (Linux)

koopa_r_configure_makeconf() {
    # """
    # Modify the 'Makeconf' file to ensure correct configuration.
    # @note Updated 2023-04-03.
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
    local -A app dict
    local -a libs
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['system']=0
    dict['use_apps']=1
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && \
        koopa_is_linux && \
        [[ ! -x "$(koopa_locate_bzip2 --allow-missing)" ]]
    then
        dict['use_apps']=0
        return 0
    fi
    app['pkg_config']="$(koopa_locate_pkg_config)"
    koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['libjpeg']="$(koopa_app_prefix 'libjpeg-turbo')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['file']="${dict['r_prefix']}/etc/Makeconf"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['icu4c']}" \
        "${dict['libiconv']}" \
        "${dict['libjpeg']}" \
        "${dict['pcre2']}" \
        "${dict['r_prefix']}" \
        "${dict['zlib']}"
    koopa_alert_info "Modifying '${dict['file']}'."
    koopa_assert_is_file "${dict['file']}"
    koopa_add_to_pkg_config_path \
        "${dict['icu4c']}/lib/pkgconfig" \
        "${dict['libjpeg']}/lib/pkgconfig" \
        "${dict['pcre2']}/lib/pkgconfig" \
        "${dict['zlib']}/lib/pkgconfig"
    libs=(
        "$("${app['pkg_config']}" --libs \
            'icu-i18n' \
            'icu-uc' \
            'libjpeg' \
            'libpcre2-8' \
            'zlib' \
        )"
        "-L${dict['bzip2']}/lib"
        "-L${dict['libiconv']}/lib"
        '-ldl'
        '-lm'
    )
    koopa_is_linux && libs+=('-lrt' '-ltirpc')
    dict['pattern']='^LIBS = .+$'
    dict['replacement']="LIBS = ${libs[*]}"
    case "${dict['system']}" in
        '0')
            koopa_find_and_replace_in_file \
                --pattern="${dict['pattern']}" \
                --replacement="${dict['replacement']}" \
                --regex \
                "${dict['file']}"
            ;;
        '1')
            koopa_find_and_replace_in_file \
                --sudo \
                --pattern="${dict['pattern']}" \
                --replacement="${dict['replacement']}" \
                --regex \
                "${dict['file']}"
            ;;
    esac
    unset -v PKG_CONFIG_PATH
    return 0
}
