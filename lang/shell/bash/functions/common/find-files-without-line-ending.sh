#!/usr/bin/env bash

koopa_find_files_without_line_ending() {
    # """
    # Find files without line ending.
    # @note Updated 2022-02-16.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    local app files prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        [pcregrep]="$(koopa_locate_pcregrep)"
    )
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        readarray -t files <<< "$(
            koopa_find \
                --min-depth=1 \
                --prefix="$(koopa_realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        koopa_is_array_non_empty "${files[@]:-}" || continue
        str="$("${app[pcregrep]}" -LMr '\n$' "${files[@]}")"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}
