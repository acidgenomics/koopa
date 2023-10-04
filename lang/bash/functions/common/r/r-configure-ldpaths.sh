#!/usr/bin/env bash

# FIXME Only do this for system macOS.

koopa_r_configure_ldpaths() {
    # """
    # Configure 'ldpaths' file for system R LD linker configuration.
    # @note Updated 2023-10-04.
    #
    # For some reason, 'LD_LIBRARY_PATH' doesn't get sorted alphabetically
    # correctly on macOS.
    #
    # Usage of ': ${KEY=VALUE}' here stores the variable internally, but does
    # not export into R session, and is not accessible with 'Sys.getenv()'.
    #
    # @section R-spatial evolution:
    #
    # R-spatial packages are being reworked. rgdal, rgeos, and maptools will be
    # retired in 2023 in favor of more modern packages, such as sf. When this
    # occurs, it may be possible to remove the geospatial libraries (geos, proj,
    # gdal) as dependencies here.
    #
    # https://r-spatial.org/r/2022/04/12/evolution.html
    #
    # @seealso
    # - https://github.com/wch/r-source/blob/HEAD/etc/ldpaths.in
    # """
    local -A app bool dict ld_lib_app_arr
    local -a keys ld_lib_arr lines
    local key
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    bool['use_apps']=1
    bool['use_java']=1
    bool['use_local']=0
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        if [[ "${bool['system']}" -eq 1 ]]
        then
            bool['use_apps']=0
            bool['use_java']=0
        fi
    elif koopa_is_macos
    then
        case "${dict['arch']}" in
            'aarch64')
                dict['arch']='arm64'
                ;;
        esac
    fi
    if [[ "${bool['use_java']}" -eq 1 ]]
    then
        dict['java_home']="$(koopa_app_prefix 'temurin')"
    else
        dict['java_home']='/usr/lib/jvm/default-java'
    fi
    koopa_assert_is_dir "${dict['java_home']}"
    lines=()
    lines+=(": \${JAVA_HOME=${dict['java_home']}}")
    if koopa_is_macos
    then
        lines+=(": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/\
libexec/Contents/Home/lib/server}")
    else
        lines+=(": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/\
libexec/lib/server}")
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        keys=(
            # > 'jpeg'
            # > 'libuv'
            'bzip2'
            'cairo'
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'graphviz'
            'harfbuzz'
            'hdf5'
            'icu4c'
            'imagemagick'
            'libffi'
            'libgit2'
            'libiconv'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl3'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
            'python3.11'
            'readline'
            'sqlite'
            'xorg-libice'
            'xorg-libpthread-stubs'
            'xorg-libsm'
            'xorg-libx11'
            'xorg-libxau'
            'xorg-libxcb'
            'xorg-libxdmcp'
            'xorg-libxext'
            'xorg-libxrandr'
            'xorg-libxrender'
            'xorg-libxt'
            'xz'
            'zlib'
            'zstd'
        )
        if koopa_is_macos || [[ "${bool['system']}" -eq 0 ]]
        then
            keys+=('gettext')
        fi
        if koopa_is_linux && [[ "${bool['system']}" -eq 0 ]]
        then
            keys+=('gcc')
        fi
        for key in "${keys[@]}"
        do
            local prefix
            prefix="$(koopa_app_prefix "$key" --allow-missing)"
            if [[ ! -d "$prefix" ]]
            then
                koopa_alert_note "Not installed: '${key}'."
                continue
            fi
            ld_lib_app_arr[$key]="$prefix"
        done
        for i in "${!ld_lib_app_arr[@]}"
        do
            case "$i" in
                'gcc')
                    ld_lib_app_arr[$i]="${ld_lib_app_arr[$i]}/lib64"
                    ;;
                *)
                    ld_lib_app_arr[$i]="${ld_lib_app_arr[$i]}/lib"
                    ;;
            esac
        done
        koopa_assert_is_dir "${ld_lib_app_arr[@]}"
    fi
    ld_lib_arr=()
    # Alternative approach, that uses absolute path:
    # > ld_lib_arr+=("${dict['r_prefix']}/lib")
    ld_lib_arr+=("\${R_HOME}/lib")
    if [[ "${bool['use_local']}" -eq 1 ]] && [[ -d '/usr/local/lib' ]]
    then
        ld_lib_arr+=('/usr/local/lib')
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        ld_lib_arr+=("${ld_lib_app_arr[@]}")
    fi
    # > if koopa_is_macos && [[ "${bool['system']}" -eq 1 ]]
    # > then
    # >     dict['r_opt_libdir']="/opt/r/${dict['arch']}/lib"
    # >     koopa_assert_is_dir "${dict['r_opt_libdir']}"
    # >     ld_lib_arr+=("${dict['r_opt_libdir']}")
    # > fi
    if koopa_is_linux
    then
        dict['sys_libdir']="/usr/lib/${dict['arch']}-linux-gnu"
        koopa_assert_is_dir "${dict['sys_libdir']}" '/usr/lib' '/lib'
        ld_lib_arr+=("${dict['sys_libdir']}" '/usr/lib' '/lib')
    fi
    ld_lib_arr+=("\${R_JAVA_LD_LIBRARY_PATH}")
    dict['library_path']="$(printf '%s:' "${ld_lib_arr[@]}")"
    lines+=(
        "R_LD_LIBRARY_PATH=\"${dict['library_path']}\""
    )
    if koopa_is_linux
    then
        lines+=(
            "LD_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}\""
            'export LD_LIBRARY_PATH'
        )
    elif koopa_is_macos
    then
        lines+=(
            "DYLD_FALLBACK_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}\""
            'export DYLD_FALLBACK_LIBRARY_PATH'
        )
    fi
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/ldpaths"
    dict['file_bak']="${dict['file']}.bak"
    koopa_assert_is_file "${dict['file']}"
    dict['string']="$(koopa_print "${lines[@]}")"
    koopa_alert_info "Modifying '${dict['file']}'."
    case "${bool['system']}" in
        '0')
            if [[ ! -f "${dict['file_bak']}" ]]
            then
                koopa_cp "${dict['file']}" "${dict['file_bak']}"
            fi
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')

            if [[ ! -f "${dict['file_bak']}" ]]
            then
                koopa_cp --sudo "${dict['file']}" "${dict['file_bak']}"
            fi
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    return 0
}
