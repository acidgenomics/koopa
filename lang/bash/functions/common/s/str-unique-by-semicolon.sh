#!/usr/bin/env bash

koopa_str_unique_by_colon() {
    # """
    # Make elements in a CMake path string separated by semicolons unique.
    # @note Updated 2023-10-11.
    #
    # Primarily intended for use during app activation, to sanitize
    # CMAKE_PREFIX_PATH, and other build variables.
    # 
    # @examples
    # koopa_str_unique_by_semicolon '/usr/lib/cmake;/usr/lib/cmake'
    # """
    local -A app
    local str str2
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        # shellcheck disable=SC2016
        str2="$( \
            koopa_print "$str" \
                | "${app['tr']}" ';' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ';' \
                | koopa_strip_right --pattern=';' \
        )"
        [[ -n "$str2" ]] || return 1
        koopa_print "$str2"
    done
    return 0
}
