#!/bin/sh
# shellcheck disable=SC2039

_koopa_disk_gb_free() { # {{{1
    # """
    # Available free disk space in GB.
    # @note Updated 2020-03-07.
    #
    # Alternatively, can use '-BG' for 1G-blocks.
    # This is what gets returned by 'df -h'.
    # """
    local disk
    disk="${1:-"/"}"
    local x
    x="$( \
        df --block-size='G' "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo '(\b[.0-9]+G\b)' \
            | head -n 3 \
            | sed -n '3p' \
            | sed 's/G$//' \
    )"
    _koopa_print "$x"
}

_koopa_disk_gb_total() { # {{{1
    # """
    # Total disk space size in GB.
    # @note Updated 2020-03-07.
    # """
    local disk
    disk="${1:-"/"}"
    local x
    x="$( \
        df --block-size='G' "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo '(\b[.0-9]+G\b)' \
            | head -n 1 \
            | sed 's/G$//' \
    )"
    _koopa_print "$x"
}

_koopa_disk_gb_used() { # {{{1
    # """
    # Used disk space in GB.
    # @note Updated 2020-03-07.
    # """
    local disk
    disk="${1:-"/"}"
    local x
    x="$( \
        df --block-size='G' "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo '(\b[.0-9]+G\b)' \
            | head -n 2 \
            | sed -n '2p' \
            | sed 's/G$//' \
    )"
    _koopa_print "$x"
}

_koopa_disk_pct_free() { # {{{1
    # """
    # Free disk space percentage (on main drive).
    # @note Updated 2020-03-07.
    # """
    local pct_used
    pct_used="$(_koopa_disk_pct_used "$@")"
    local pct_free
    pct_free="$((100 - pct_used))"
    _koopa_print "$pct_free"
}

_koopa_disk_pct_used() { # {{{1
    # """
    # Disk usage percentage (on main drive).
    # @note Updated 2020-03-07.
    # """
    local disk
    disk="${1:-"/"}"
    local x
    x="$( \
        df "$disk" \
            | head -n 2 \
            | sed -n '2p' \
            | grep -Eo "([.0-9]+%)" \
            | head -n 1 \
            | sed 's/%$//' \
    )"
    _koopa_print "$x"
}
