#!/usr/bin/env bash

koopa_lesspipe_version() {
    # """
    # lesspipe.sh version.
    # @note Updated 2022-03-18.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [lesspipe]="${1:-}"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -z "${app[lesspipe]}" ]] && app[lesspipe]="$(koopa_locate_lesspipe)"
    str="$( \
        "${app[cat]}" "${app[lesspipe]}" \
            | "${app[sed]}" -n '2p' \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
