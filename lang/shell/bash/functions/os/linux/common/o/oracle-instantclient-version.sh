#!/usr/bin/env bash

koopa_linux_oracle_instantclient_version() {
    # """
    # Oracle InstantClient version.
    # @note Updated 2022-08-26.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['sqlplus']="$(koopa_linux_locate_sqlplus)"
    )
    [[ -x "${app['sqlplus']}" ]] || exit 1
    str="$( \
        "${app['sqlplus']}" -v \
            | koopa_grep --pattern='^Version' --regex \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
