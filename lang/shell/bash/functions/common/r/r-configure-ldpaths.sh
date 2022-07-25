#!/usr/bin/env bash

koopa_r_configure_ldpaths() {
    # """
    # Configure 'ldpaths' file for system R LD linker configuration.
    # @note Updated 2022-07-25.
    #
    # Usage of ': ${KEY=VALUE}' here stores the variable internally, but does
    # not export into R session, and is not accessible with 'Sys.getenv()'.
    # """
    local app dict key keys ld_lib_arr ld_lib_opt_arr lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
    )
    [[ -x "${app[r]}" ]] || return 1
    koopa_is_koopa_app "${app[r]}" && return 0
    koopa_is_linux || return 0
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
    )
    dict[file]="${dict[r_prefix]}/etc/ldpaths"
    dict[java_home]="$(koopa_realpath "${dict[opt_prefix]}/openjdk")"
    koopa_alert "Configuring '${dict[file]}'."
    lines=()
    lines+=(
        ": \${JAVA_HOME=${dict[java_home]}}"
        ": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/libexec/lib/server}"
    )
    declare -A ld_lib_opt_arr
    keys=(
        'fontconfig'
        'freetype'
        'gdal'
        'geos'
        'imagemagick'
        'libgit2'
        'proj'
    )
    for key in "${keys[@]}"
    do
        ld_lib_opt_arr[$key]="$( \
            koopa_realpath "${dict[opt_prefix]}/${key}/lib" \
        )"
    done
    ld_lib_arr=(
        "/usr/lib/${dict[arch]}-linux-gnu"
        "\${R_HOME}/lib"
        "${ld_lib_opt_arr[@]}"
        "\${R_JAVA_LD_LIBRARY_PATH}"
    )
    lines+=(
        "LD_LIBRARY_PATH=$(printf '%s:' "${ld_lib_arr[@]}")"
        'export LD_LIBRARY_PATH'
    )
    dict[string]="$(koopa_print "${lines[@]}")"
    # This should only apply to R CRAN binary, not source install.
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}
