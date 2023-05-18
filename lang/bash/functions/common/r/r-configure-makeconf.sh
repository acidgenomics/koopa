#!/usr/bin/env bash

koopa_r_configure_makeconf() {
    # """
    # Modify the 'Makeconf' file to ensure correct configuration.
    # @note Updated 2023-05-18.
    #
    # @seealso
    # - /opt/koopa/opt/r/lib/R/etc/Makeconf
    # - /Library/Frameworks/R.framework/Versions/Current/Resources/etc/Makeconf
    # - https://github.com/wch/r-source/blob/trunk/Makeconf.in
    # """
    local -A app bool dict
    local -a libs
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    [[ "${bool['system']}" -eq 1 ]] && bool['use_apps']=0
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        app['pkg_config']="$(koopa_locate_pkg_config)"
        koopa_assert_is_executable "${app[@]}"
        dict['bzip2']="$(koopa_app_prefix 'bzip2')"
        dict['icu4c']="$(koopa_app_prefix 'icu4c')"
        dict['libjpeg']="$(koopa_app_prefix 'libjpeg-turbo')"
        dict['libiconv']="$(koopa_app_prefix 'libiconv')"
        dict['pcre2']="$(koopa_app_prefix 'pcre2')"
        dict['zlib']="$(koopa_app_prefix 'zlib')"
        koopa_assert_is_dir \
            "${dict['bzip2']}" \
            "${dict['icu4c']}" \
            "${dict['libiconv']}" \
            "${dict['libjpeg']}" \
            "${dict['pcre2']}" \
            "${dict['zlib']}"
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
        if koopa_is_linux
        then
            libs+=('-lrt' '-ltirpc')
        fi
    else
        # > libs=('-lbz2' '-ldl' '-llzma' '-lm' '-lpcre2-8' '-lz')
        # > if koopa_is_macos
        # > then
        # >     libs+=('-liconv' '-licucore')
        # > elif koopa_is_linux
        # > then
        # >     libs+=('-licui18n' '-licuuc' '-lrt' '-ltirpc')
        # > fi
        return 0
    fi
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/Makeconf"
    dict['file_bak']="${dict['file']}.bak"
    koopa_assert_is_file "${dict['file']}"
    koopa_alert_info "Modifying '${dict['file']}'."
    dict['pattern']='^LIBS = .+$'
    dict['replacement']="LIBS = ${libs[*]}"
    case "${bool['system']}" in
        '0')
            if [[ ! -f "${dict['file.bak']}" ]]
            then
                koopa_cp "${dict['file']}" "${dict['file.bak']}"
            fi
            koopa_find_and_replace_in_file \
                --pattern="${dict['pattern']}" \
                --replacement="${dict['replacement']}" \
                --regex \
                "${dict['file']}"
            ;;
        '1')
            if [[ ! -f "${dict['file.bak']}" ]]
            then
                koopa_cp --sudo "${dict['file']}" "${dict['file.bak']}"
            fi
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
