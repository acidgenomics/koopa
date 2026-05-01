#!/usr/bin/env bash

_koopa_linux_oracle_instantclient_version() {
    # """
    # Oracle InstantClient version.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['sqlplus']="$(_koopa_linux_locate_sqlplus)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['sqlplus']}" -v \
            | _koopa_grep --pattern='^Version' --regex \
            | _koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
