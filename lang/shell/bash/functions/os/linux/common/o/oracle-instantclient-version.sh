#!/usr/bin/env bash

koopa_linux_oracle_instantclient_version() {
    # """
    # Oracle InstantClient version.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['sqlplus']="$(koopa_linux_locate_sqlplus)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['sqlplus']}" -v \
            | koopa_grep --pattern='^Version' --regex \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
