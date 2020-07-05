#!/usr/bin/env bash

koopa::rsync_flags() { # {{{1
    # """
    # rsync flags.
    # @note Updated 2020-04-06.
    #
    #     --delete-before         receiver deletes before xfer, not during
    #     --iconv=CONVERT_SPEC    request charset conversion of filenames
    #     --numeric-ids           don't map uid/gid values by user/group name
    #     --partial               keep partially transferred files
    #     --progress              show progress during transfer
    # -A, --acls                  preserve ACLs (implies -p)
    # -H, --hard-links            preserve hard links
    # -L, --copy-links            transform symlink into referent file/dir
    # -O, --omit-dir-times        omit directories from --times
    # -P                          same as --partial --progress
    # -S, --sparse                handle sparse files efficiently
    # -X, --xattrs                preserve extended attributes
    # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
    # -g, --group                 preserve group
    # -h, --human-readable        output numbers in a human-readable format
    # -n, --dry-run               perform a trial run with no changes made
    # -o, --owner                 preserve owner (super-user only)
    # -r, --recursive             recurse into directories
    # -x, --one-file-system       don't cross filesystem boundaries    
    # -z, --compress              compress file data during the transfer
    #
    # Use '--rsync-path="sudo rsync"' to sync across machines with sudo.
    #
    # See also:
    # - https://unix.stackexchange.com/questions/165423
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '--archive --delete-before --human-readable --progress'
    return 0
}

koopa::rsync_flags_macos() { # {{{1
    # """
    # macOS rsync flags.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::print "$(koopa::rsync_flags) --iconv=utf-8,utf-8-mac"
    return 0
}

koopa::rsync_vm() { # {{{1
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
    if [[ "$source_ip" == "$host_ip" ]]
    then
        koopa::note "On source machine: '${source_ip}'."
        return 0
    fi
    koopa::h1 "Syncing '${prefix}' from '${source_ip}'."
    koopa::dl "Flags" "$flags"
    koopa::mkdir "$prefix"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions --recursive --user "$prefix"
    # Note that this step won't work unless we leave 'flags' unquoted here.
    # shellcheck disable=SC2086
    rsync $flags \
        --rsync-path="sudo ${rsync}" \
        "${user}@${source_ip}:${prefix}/" \
        "${prefix}/"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions --recursive "$prefix"
    return 0
}
