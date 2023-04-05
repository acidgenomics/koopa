#!/usr/bin/env bash

koopa_r_koopa() {
    # """
    # Execute a function in koopa R package.
    # @note Updated 2023-04-04.
    #
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    # """
    local -A app dict
    local -a code pos rscript_args
    local header_file fun
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript)"
    koopa_assert_is_executable "${app[@]}"
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
    dict['fun']="${1:?}"
    shift 1
    dict['header_file']="$(koopa_koopa_prefix)/lang/r/include/header.R"
    koopa_assert_is_file "${dict['header_file']}"
    code=("source('${dict['header_file'}');")
    if [[ "${dict['fun']}" != 'header' ]]
    then
        code+=("koopa::${dict['fun']}();")
    fi
    pos=("$@")
    "${app['rscript']}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}
