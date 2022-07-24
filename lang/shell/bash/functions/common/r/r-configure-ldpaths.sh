#!/usr/bin/env bash

koopa_r_configure_ldpaths() {
    # """
    # Configure 'ldpaths' file for system R LD linker configuration.
    # @note Updated 2022-07-24.
    #
    # Usage of ': ${KEY=VALUE}' here stores the variable internally, but does
    # not export into R session, and is not accessible with 'Sys.getenv()'.
    # """
    local app dict
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
    dict[fontconfig]="$(koopa_realpath "${dict[opt_prefix]}/fontconfig")"
    dict[freetype]="$(koopa_realpath "${dict[opt_prefix]}/freetype")"
    dict[gdal]="$(koopa_realpath "${dict[opt_prefix]}/gdal")"
    dict[geos]="$(koopa_realpath "${dict[opt_prefix]}/geos")"
    dict[imagemagick]="$(koopa_realpath "${dict[opt_prefix]}/imagemagick")"
    dict[libgit2]="$(koopa_realpath "${dict[opt_prefix]}/libgit2")"
    dict[proj]="$(koopa_realpath "${dict[opt_prefix]}/proj")"
    read -r -d '' "dict[string]" << END || true
: \${JAVA_HOME=${dict[java_home]}}
: \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/libexec/lib/server}
LD_LIBRARY_PATH=""
LD_LIBRARY_PATH="/usr/lib/${dict[arch]}-linux-gnu:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="\${R_HOME}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[fontconfig]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[freetype]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[gdal]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[geos]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[imagemagick]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[libgit2]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${dict[proj]}/lib:\${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${R_JAVA_LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH
END
    # This should only apply to R CRAN binary, not source install.
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}
