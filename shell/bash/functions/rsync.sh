#!/usr/bin/env bash

_koopa_rsync_vm() {
    # """
    # rsync a desired prefix across virtual machines.
    # @note Updated 2020-02-16.
    #
    # Potentially useful flags:
    # * --omit-dir-times
    # """
    # We're enforcing use of '/usr/bin/rsync' here in case we're syncing
    # '/usr/local', which may have an updated copy of rsync installed.
    local rsync
    rsync="/usr/bin/rsync"
    _koopa_assert_is_installed "$rsync"

    local flags
    flags="$(_koopa_rsync_flags)"

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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done

    _koopa_assert_is_set flags prefix source_ip

    local host_ip
    host_ip="$(ip-address)"

    local user
    user="${USER:?}"

    # Check for accidental sync from source machine.
    if [ "$source_ip" == "$host_ip" ]
    then
        _koopa_note "On source machine: '${source_ip}'."
        return 1
    fi

    _koopa_h1 "Syncing '${prefix}' from '${source_ip}'."
    _koopa_dl "Flags" "$flags"

    sudo mkdir -pv "$prefix"
    sudo chown -Rh "$user" "$prefix"

    # Note that this step won't work unless we leave 'flags' unquoted here.
    # shellcheck disable=SC2086
    rsync $flags \
        --rsync-path="sudo ${rsync}" \
        "${user}@${source_ip}:${prefix}/" \
        "${prefix}/"

    _koopa_set_permissions "$prefix"
    return 0
}
