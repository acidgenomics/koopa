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

koopa::rsync_ignore() { # {{{1
    # """
    # Run rsync with automatic ignore.
    # @note Updated 2020-07-10.
    # @seealso
    # https://stackoverflow.com/questions/13713101/
    # """
    local global ignore_global pos rsync_flags
    koopa::assert_has_args "$#"
    koopa::assert_is_installed rsync
    global=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --global)
                global=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    rsync_flags=(
        # '--exclude=.*/'
        # '--exclude=/.git'
        # '--filter=:- .gitignore'
        '--archive'
        '--exclude=.*'
        '--filter=dir-merge,- .gitignore'
        '--human-readable'
        '--progress'
    )
    if [[ "$global" -eq 1 ]]
    then
        ignore_global="${HOME}/.gitignore"
        koopa::assert_is_file "$ignore_global"
        rsync_flags+=("--filter=dir-merge,- ${ignore_global}")
    fi
    rsync "${rsync_flags[@]}" "$@"
    return 0
}

koopa::rsync_vm() { # {{{1
    # """
    # rsync a desired prefix across virtual machines.
    # @note Updated 2020-07-06.
    #
    # Potentially useful flags:
    # * --omit-dir-times
    # """
    # We're enforcing use of '/usr/bin/rsync' here in case we're syncing
    # '/usr/local', which may have an updated copy of rsync installed.
    local host_ip prefix rsync rsync_flags source_ip user
    koopa::assert_has_args "$#"
    rsync='/usr/bin/rsync'
    koopa::assert_is_installed "$rsync"
    rsync_flags="$(koopa::rsync_flags)"
    while (("$#"))
    do
        case "$1" in
            --rsync-flags=*)
                rsync_flags="${1#*=}"
                shift 1
                ;;
            --rsync-flags)
                rsync_flags="$2"
                shift 2
                ;;
            --prefix=*)
                prefix="${1#*=}"
                shift 1
                ;;
            --prefix)
                prefix="$2"
                shift 2
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            --source-ip)
                source_ip="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    koopa::assert_is_set flags prefix source_ip
    host_ip="$(koopa::local_ip_address)"
    # Check for accidental sync from source machine.
    if [[ "$source_ip" == "$host_ip" ]]
    then
        koopa::note "On source machine: '${source_ip}'."
        return 0
    fi
    rsync_flags=("$rsync_flags")
    rsync_flags+=("--rsync-path=sudo ${rsync}")
    user="${USER:?}"
    koopa::h1 "Syncing '${prefix}' from '${source_ip}'."
    koopa::dl "Flags" "${rsync_flags[*]}"
    koopa::sys_mkdir "$prefix"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions -ru "$prefix"
    rsync "${rsync_flags[@]}" \
        "${user}@${source_ip}:${prefix}/" \
        "${prefix}/"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}
