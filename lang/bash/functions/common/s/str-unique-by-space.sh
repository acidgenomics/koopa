#!/usr/bin/env bash

koopa_str_unique_by_space() {
    # """
    # Make elements in a string separated by spaces unique.
    # @note Updated 2023-10-11.
    #
    # Primarily intended for use during app activation, to sanitize CPPFLAGS,
    # LDFLAGS, and other build variables.
    #
    # @seealso
    # - https://stackoverflow.com/questions/13648410/
    # 
    # @examples
    # koopa_str_unique_by_space \
    #   '-I/usr/include -I/usr/include' \
    #   '-L/usr/lib -L/usr/lib'
    # """
    local -A app
    local str str2
    koopa_assert_has_args "$#"
    app['tr']="$(koopa_locate_tr --allow-system)"
    app['uniq']="$(koopa_locate_uniq --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            koopa_print "$str" \
                | "${app['tr']}" ' ' '\n' \
                | "${app['uniq']}" \
                | "${app['tr']}" '\n' ' ' \
        )"
        [[ -n "$str2" ]] || return 1
        koopa_print "$str2"
    done
    return 0
}
