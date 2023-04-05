#!/usr/bin/env bash

koopa_r_koopa() {
    # """
    # Execute a function in koopa R package.
    # @note Updated 2023-04-04.
    #
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    # """
    local app code header_file fun pos rscript_args
    local -A app
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript)"
    [[ -x "${app['rscript']}" ]] || exit 1
    rscript_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--vanilla')
                rscript_args+=('--vanilla')
                shift 1
                ;;
            '--'*)
                pos+=("$1")
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    fun="${1:?}"
    shift 1
    header_file="$(koopa_koopa_prefix)/lang/r/include/header.R"
    koopa_assert_is_file "$header_file"
    code=("source('${header_file}');")
    if [[ "$fun" != 'header' ]]
    then
        code+=("koopa::${fun}();")
    fi
    pos=("$@")
    "${app['rscript']}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}
