#!/usr/bin/env bash

koopa_disk_gb_total() {
    # """
    # Total disk space size in GB.
    # @note Updated 2022-05-06.
    # """
    local app disk str
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa_locate_df)"
        [head]="$(koopa_locate_head)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[df]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa_grep \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
                --regex \
            | "${app[head]}" -n 1 \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
