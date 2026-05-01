#!/usr/bin/env bash

_koopa_str_unique_by_colon() {
    # """
    # Make elements in a path string separated by colons unique.
    # @note Updated 2023-10-11.
    #
    # Primarily intended for use during app activation, to sanitize PATH,
    # LIBRARY_PATH, and other build variables.
    # 
    # @examples
    # _koopa_str_unique_by_colon '/usr/bin:/usr/bin'
    # """
    local -A app
    local str str2
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        # shellcheck disable=SC2016
        str2="$( \
            _koopa_print "$str" \
                | "${app['tr']}" ':' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ':' \
                | _koopa_strip_right --pattern=':' \
        )"
        [[ -n "$str2" ]] || return 1
        _koopa_print "$str2"
    done
    return 0
}
