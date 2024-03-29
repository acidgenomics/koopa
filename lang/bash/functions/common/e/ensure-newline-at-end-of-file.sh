#!/usr/bin/env bash

koopa_ensure_newline_at_end_of_file() {
    # """
    # Ensure output CSV contains trailing line break.
    # @note Updated 2023-04-05.
    #
    # Otherwise 'readr::read_csv()' will skip the last line in R.
    # https://unix.stackexchange.com/questions/31947
    #
    # Slower alternatives:
    # vi -ecwq file
    # paste file 1<> file
    # ed -s file <<< w
    # sed -i -e '$a\' file
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:?}"
    [[ -n "$("${app['tail']}" --bytes=1 "${dict['file']}")" ]] || return 0
    printf '\n' >> "${dict['file']}"
    return 0
}
