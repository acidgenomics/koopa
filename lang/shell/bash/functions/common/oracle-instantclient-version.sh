#!/usr/bin/env bash

koopa_oracle_instantclient_version() {
    # """
    # Oracle InstantClient version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sqlplus]="$(koopa_locate_sqlplus)"
    )
    str="$( \
        "${app[sqlplus]}" -v \
            | koopa_grep --pattern='^Version' --regex \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
