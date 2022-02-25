#!/usr/bin/env bash

koopa_disk_gb_free() { # {{{1
    # """
    # Available free disk space in GB.
    # @note Updated 2022-02-23.
    #
    # Alternatively, can use '-BG' for 1G-blocks.
    # This is what gets returned by 'df -h'.
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
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" --lines=2 \
            | "${app[sed]}" --quiet '2p' \
            | koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
            | "${app[head]}" --lines=3 \
            | "${app[sed]}" --quiet '3p' \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_disk_gb_total() { # {{{1
    # """
    # Total disk space size in GB.
    # @note Updated 2022-02-23.
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
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" --lines=2 \
            | "${app[sed]}" --quiet '2p' \
            | koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
            | "${app[head]}" --lines=1 \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_disk_gb_used() { # {{{1
    # """
    # Used disk space in GB.
    # @note Updated 2022-02-23.
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
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" --lines=2 \
            | "${app[sed]}" --quiet '2p' \
            | koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
            | "${app[head]}" --lines=2 \
            | "${app[sed]}" --quiet '2p' \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_disk_pct_free() { # {{{1
    # """
    # Free disk space percentage (on main drive).
    # @note Updated 2021-10-25.
    # """
    local disk pct_free pct_used
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    pct_used="$(koopa_disk_pct_used "$disk")"
    pct_free="$((100 - pct_used))"
    koopa_print "$pct_free"
    return 0
}

koopa_disk_pct_used() { # {{{1
    # """
    # Disk usage percentage (on main drive).
    # @note Updated 2022-02-23.
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
    str="$( \
        "${app[df]}" "$disk" \
            | "${app[head]}" --lines=2 \
            | "${app[sed]}" --quiet '2p' \
            | koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern='([.0-9]+%)' \
            | "${app[head]}" --lines=1 \
            | "${app[sed]}" 's/%$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
