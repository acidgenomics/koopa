#!/usr/bin/env bash

# NOTE Don't include graphviz here, as it can cause conflicts with Rgraphviz
# package in R, which bundles a very old version (2.28.0) currently.

koopa_r_configure_ldpaths() {
    # """
    # Configure 'ldpaths' file for system R LD linker configuration.
    # @note Updated 2022-09-20.
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
    declare -A app
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['java_home']="$(koopa_app_prefix 'openjdk')"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['system']=0
    )
    koopa_assert_is_dir \
        "${dict['java_home']}" \
        "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/ldpaths"
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    koopa_alert "Configuring '${dict['file']}'."
    lines=()
    lines+=(
        ": \${JAVA_HOME=${dict['java_home']}}"
        ": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/libexec/lib/server}"
    )
    declare -A ld_lib_app_arr
    keys=(
        'bzip2'
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
        'jpeg'
        'lapack'
        'libgit2'
        'libiconv'
        'libjpeg-turbo'
        'libpng'
        'libssh2'
        'libtiff'
        # > 'libuv'
        'libxml2'
        'openblas'
        'openssl3'
        'pcre'
        'pcre2'
        'proj'
        'python'
        'readline'
        'sqlite'
        'xz'
        'zlib'
        'zstd'
    )
    if koopa_is_macos || [[ "${dict['system']}" -eq 0 ]]
    then
        keys+=('gettext')
    fi
    for key in "${keys[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix "$key")"
        koopa_assert_is_dir "$prefix"
        ld_lib_app_arr[$key]="$prefix"
    done
    for i in "${!ld_lib_app_arr[@]}"
    do
        ld_lib_app_arr[$i]="${ld_lib_app_arr[$i]}/lib"
    done
    if koopa_is_linux
    then
        ld_lib_app_arr['glib']="${ld_lib_app_arr['glib']}64"
        ld_lib_app_arr['harfbuzz']="${ld_lib_app_arr['harfbuzz']}64"
    fi
    koopa_assert_is_dir "${ld_lib_app_arr[@]}"
    ld_lib_arr=()
    ld_lib_arr+=(
        "\${R_HOME}/lib"
        "${ld_lib_app_arr[@]}"
    )
    if koopa_is_linux
    then
        local sys_libdir
        sys_libdir="/usr/lib/${dict['arch']}-linux-gnu"
        koopa_assert_is_dir "$sys_libdir"
        ld_lib_arr+=("$sys_libdir")
    fi
    ld_lib_arr+=(
        '/usr/lib'
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
