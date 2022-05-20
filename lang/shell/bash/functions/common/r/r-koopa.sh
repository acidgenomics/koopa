#!/usr/bin/env bash

koopa_r_koopa() {
    # """
    # Execute a function in koopa R package.
    # @note Updated 2021-10-29.
    # """
    local app code header_file fun pos rscript_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
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
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    if [[ "$fun" != 'header' ]]
    then
        code+=("koopa::${fun}();")
    fi
    # Ensure positional arguments get properly quoted (escaped).
    pos=("$@")
    "${app[rscript]}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}
