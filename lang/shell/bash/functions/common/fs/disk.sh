#!/usr/bin/env bash

# NOTE These statistics can return incorrectly for macOS APFS volumes.

koopa::disk_gb_free() { # {{{1
    # """
    # Available free disk space in GB.
    # @note Updated 2021-10-25.
    #
    # Alternatively, can use '-BG' for 1G-blocks.
    # This is what gets returned by 'df -h'.
    # """
    local app disk x
    koopa::assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa::assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa::locate_df)"
        [head]="$(koopa::locate_head)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa::grep \
                --extended-regexp \
                --only-matching \
                '(\b[.0-9]+G\b)' \
            | "${app[head]}" -n 3 \
            | "${app[sed]}" -n '3p' \
            | "${app[sed]}" 's/G$//' \
    )"
    koopa::print "$x"
    return 0
}

koopa::disk_gb_total() { # {{{1
    # """
    # Total disk space size in GB.
    # @note Updated 2021-10-25.
    # """
    local app disk x
    koopa::assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa::assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa::locate_df)"
        [head]="$(koopa::locate_head)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa::grep \
                --extended-regexp \
                --only-matching \
                '(\b[.0-9]+G\b)' \
            | "${app[head]}" -n 1 \
            | "${app[sed]}" 's/G$//' \
    )"
    koopa::print "$x"
    return 0
}

koopa::disk_gb_used() { # {{{1
    # """
    # Used disk space in GB.
    # @note Updated 2021-10-25.
    # """
    local app disk x
    koopa::assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa::assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa::locate_df)"
        [head]="$(koopa::locate_head)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa::grep \
                --extended-regexp \
                --only-matching \
                '(\b[.0-9]+G\b)' \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | "${app[sed]}" 's/G$//' \
    )"
    koopa::print "$x"
    return 0
}

koopa::disk_pct_free() { # {{{1
    # """
    # Free disk space percentage (on main drive).
    # @note Updated 2021-10-25.
    # """
    local disk pct_free pct_used
    koopa::assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa::assert_is_readable "$disk"
    pct_used="$(koopa::disk_pct_used "$disk")"
    pct_free="$((100 - pct_used))"
    koopa::print "$pct_free"
    return 0
}

koopa::disk_pct_used() { # {{{1
    # """
    # Disk usage percentage (on main drive).
    # @note Updated 2021-10-25.
    # """
    local app disk x
    koopa::assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa::assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa::locate_df)"
        [head]="$(koopa::locate_head)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        "${app[df]}" "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa::grep \
                --extended-regexp \
                --only-matching \
                '([.0-9]+%)' \
            | "${app[head]}" -n 1 \
            | "${app[sed]}" 's/%$//' \
    )"
    koopa::print "$x"
    return 0
}
