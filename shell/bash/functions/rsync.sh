#!/usr/bin/env bash

koopa::rsync_vm() {
    # """
    # rsync a desired prefix across virtual machines.
    # @note Updated 2020-02-18.
    #
    # Potentially useful flags:
    # * --omit-dir-times
    # """
    # We're enforcing use of '/usr/bin/rsync' here in case we're syncing
    # '/usr/local', which may have an updated copy of rsync installed.
    local rsync
    rsync="/usr/bin/rsync"
    koopa::assert_is_installed "$rsync"
    local flags
    flags="$(koopa::rsync_flags)"
    while (("$#"))
    do
        case "$1" in
            --flags=*)
                local flags="${1#*=}"
                shift 1
                ;;
            --prefix=*)
                local prefix="${1#*=}"
                shift 1
                ;;
            --source-ip=*)
                local source_ip="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set flags prefix source_ip
    local host_ip
    host_ip="$(koopa::local_ip_address)"
    local user
    user="${USER:?}"
    # Check for accidental sync from source machine.
    if [ "$source_ip" == "$host_ip" ]
    then
        koopa::note "On source machine: '${source_ip}'."
        return 0
    fi
    koopa::h1 "Syncing '${prefix}' from '${source_ip}'."
    koopa::dl "Flags" "$flags"
    koopa::mkdir "$prefix"
    koopa::remove_broken_symlinks "$prefix"
    koopa::system_set_permissions --recursive --user "$prefix"
    # Note that this step won't work unless we leave 'flags' unquoted here.
    # shellcheck disable=SC2086
    rsync $flags \
        --rsync-path="sudo ${rsync}" \
        "${user}@${source_ip}:${prefix}/" \
        "${prefix}/"
    koopa::remove_broken_symlinks "$prefix"
    koopa::system_set_permissions --recursive "$prefix"
    return 0
}
