#!/bin/sh

koopa::disk_gb_free() { # {{{1
    # """
    # Available free disk space in GB.
    # @note Updated 2020-06-30.
    #
    # Alternatively, can use '-BG' for 1G-blocks.
    # This is what gets returned by 'df -h'.
    # """
    local disk x
    disk="${1:-"/"}"
    x="$( \
        df --block-size='G' "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo '(\b[.0-9]+G\b)' \
            | head -n 3 \
            | sed -n '3p' \
            | sed 's/G$//' \
    )"
    koopa::print "$x"
    return 0
}

koopa::disk_gb_total() { # {{{1
    # """
    # Total disk space size in GB.
    # @note Updated 2020-06-30.
    # """
    local disk x
    disk="${1:-"/"}"
    x="$( \
        df --block-size='G' "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo '(\b[.0-9]+G\b)' \
            | head -n 1 \
            | sed 's/G$//' \
    )"
    koopa::print "$x"
    return 0
}

koopa::disk_gb_used() { # {{{1
    # """
    # Used disk space in GB.
    # @note Updated 2020-06-30.
    # """
    local disk x
    disk="${1:-"/"}"
    x="$( \
        df --block-size='G' "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo '(\b[.0-9]+G\b)' \
            | head -n 2 \
            | sed -n '2p' \
            | sed 's/G$//' \
    )"
    koopa::print "$x"
    return 0
}

koopa::disk_pct_free() { # {{{1
    # """
    # Free disk space percentage (on main drive).
    # @note Updated 2020-06-30.
    # """
    local disk pct_free pct_used
    disk="${1:-"/"}"
    pct_used="$(koopa::disk_pct_used "$disk")"
    pct_free="$((100 - pct_used))"
    koopa::print "$pct_free"
    return 0
}

koopa::disk_pct_used() { # {{{1
    # """
    # Disk usage percentage (on main drive).
    # @note Updated 2020-06-30.
    # """
    local disk x
    disk="${1:-"/"}"
    x="$( \
        df "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo "([.0-9]+%)" \
            | head -n 1 \
            | sed 's/%$//' \
    )"
    koopa::print "$x"
    return 0
}
