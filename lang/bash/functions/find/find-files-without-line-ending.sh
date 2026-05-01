#!/usr/bin/env bash

_koopa_find_files_without_line_ending() {
    # """
    # Find files without line ending.
    # @note Updated 2023-04-05.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    app['pcregrep']="$(_koopa_locate_pcregrep)"
    _koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -a files
        local str
        readarray -t files <<< "$(
            _koopa_find \
                --min-depth=1 \
                --prefix="$(_koopa_realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        _koopa_is_array_non_empty "${files[@]:-}" || continue
        str="$("${app['pcregrep']}" -LMr '\n$' "${files[@]}")"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}
