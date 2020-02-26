#!/bin/sh
# shellcheck disable=SC2039

_koopa_disk_check() {  # {{{1
    # """
    # Check that disk has enough free space.
    # @note Updated 2019-10-27.
    # """
    local used
    local limit
    used="$(_koopa_disk_pct_used "$@")"
    limit="90"
    if [ "$used" -gt "$limit" ]
    then
        _koopa_warning "Disk usage is ${used}%."
    fi
    return 0
}

_koopa_disk_pct_used() {  # {{{1
    # """
    # Check disk usage on main drive.
    # @note Updated 2020-02-13.
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
    echo "$x"
    return 0
}

_koopa_tmux_sessions() {  # {{{1
    # """
    # Show active tmux sessions.
    # @note Updated 2020-02-26.
    # """
    _koopa_is_installed tmux || return 0
    local x
    x="$(tmux ls 2>/dev/null || true)"
    [ -n "$x" ] || return 0
    x="$(echo "$x" | cut -d ':' -f 1 | tr '\n' ' ')"
    _koopa_dl "tmux sessions" "$x"
    return 0
}

_koopa_today_bucket() {  # {{{1
    # """
    # Create a dated file today bucket.
    # @note Updated 2020-02-24.
    #
    # Also adds a '~/today' symlink for quick access.
    #
    # How to check if a symlink target matches a specific path:
    # https://stackoverflow.com/questions/19860345
    #
    # Useful link flags:
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    # """
    local bucket_dir
    bucket_dir="${HOME:?}/bucket"
    # Early return if there's no bucket directory on the system.
    [ -d "$bucket_dir" ] || return 0
    local today_bucket
    today_bucket="$(date +"%Y/%m/%d")"
    local today_link
    today_link="${HOME}/today"
    # Early return if we've already updated the symlink.
    if readlink "$today_link" | grep -q "$today_bucket"
    then
        return 0
    fi
    mkdir -p "${bucket_dir}/${today_bucket}"
    ln -fns "${bucket_dir}/${today_bucket}" "$today_link"
    return 0
}
