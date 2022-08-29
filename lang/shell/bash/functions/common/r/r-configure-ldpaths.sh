#!/usr/bin/env bash

# NOTE Don't include graphviz here, as it can cause conflicts with Rgraphviz
# package in R, which bundles a very old version (2.28.0) currently.

koopa_r_configure_ldpaths() {
    # """
    # Configure 'ldpaths' file for system R LD linker configuration.
    # @note Updated 2022-08-29.
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
    # """
    local app dict key keys ld_lib_arr ld_lib_app_arr lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['r']="${1:?}"
    )
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['system']=0
    )
    dict['file']="${dict['r_prefix']}/etc/ldpaths"
    dict['java_home']="$(koopa_realpath "${dict['opt_prefix']}/openjdk")"
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    koopa_alert "Configuring '${dict['file']}'."
    lines=()
    lines+=(
        ": \${JAVA_HOME=${dict['java_home']}}"
        ": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/libexec/lib/server}"
    )
    declare -A ld_lib_app_arr
    keys=(
        'fontconfig'
        'freetype'
        'fribidi'
        'gdal'
        'geos'
        'graphviz'
        'harfbuzz'
        'icu4c'
        'imagemagick'
        'jpeg'
        'lapack'
        'libgit2'
        'libjpeg-turbo'
        'libpng'
        'libssh2'
        'libtiff'
        'libuv'
        'openblas'
        'openssl3'
        'pcre2'
        'proj'
        'readline'
        'xz'
        'zlib'
        'zstd'
    )
    for key in "${keys[@]}"
    do
        local dict2
        declare -A dict2
        dict2['prefix']="$(koopa_app_prefix "$key")"
        koopa_assert_is_dir "${dict2['prefix']}"
        dict2['libdir']="${dict2['prefix']}/lib"
        koopa_assert_is_dir "${dict2['libdir']}"
        ld_lib_app_arr[$key]="${dict2['libdir']}"
    done
    ld_lib_arr=()
    if koopa_is_linux
    then
        local sys_libdir
        sys_libdir="/usr/lib/${dict['arch']}-linux-gnu"
        koopa_assert_is_dir "$sys_libdir"
        ld_lib_arr+=("$sys_libdir")
    fi
    ld_lib_arr+=(
        "\${R_HOME}/lib"
        "${ld_lib_app_arr[@]}"
        "\${R_JAVA_LD_LIBRARY_PATH}"
    )
    lines+=(
        "LD_LIBRARY_PATH=\"$(printf '%s:' "${ld_lib_arr[@]}")\""
        'export LD_LIBRARY_PATH'
    )
    if koopa_is_macos
    then
        lines+=(
            "DYLD_FALLBACK_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}\""
            'export DYLD_FALLBACK_LIBRARY_PATH'
        )
    fi
    dict['string']="$(koopa_print "${lines[@]}")"
    case "${dict['system']}" in
        '0')
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    return 0
}
