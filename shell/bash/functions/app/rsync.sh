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
    # @note Updated 2020-08-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::rsync_flags) --iconv=utf-8,utf-8-mac"
    return 0
}

koopa::rsync_ignore() { # {{{1
    # """
    # Run rsync with automatic ignore.
    # @note Updated 2020-08-04.
    # @seealso
    # https://stackoverflow.com/questions/13713101/
    # """
    local ignore_global rsync_flags
    koopa::assert_has_args "$#"
    koopa::assert_is_installed rsync
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
    ignore_global="${HOME}/.gitignore"
    if [[ -f "$ignore_global" ]]
    then
        rsync_flags+=("--filter=dir-merge,- ${ignore_global}")
    fi
    rsync "${rsync_flags[@]}" "$@"
    return 0
}
