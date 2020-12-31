#!/usr/bin/env bash

# FIXME CREATE AN ASSERT CHECK FOR NO FLAGS.

# FIXME CHECK FOR FLAGS AND DONT ALLOW HERE.
koopa::clone() { # {{{1
    # """
    # Clone files using rsync (with saner defaults).
    # @note Updated 2020-12-31.
    # """
    local flags
    flags=(
        '--archive'
        '--delete-before'
    )
    koopa::rsync "${flags[@]}" "$@"
    return 0
}

koopa::rsync() { # {{{1
    # """
    # GNU rsync wrapper.
    # @note Updated 2020-12-31.
    #
    # Useful flags:
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
    local flags
    koopa::assert_has_gnu_rsync
    flags=(
        # > '--delete-before'
        '--archive'
        '--human-readable'
        '--progress'
        '--protect-args'
    )
    if koopa::is_macos
    then
        flags+=(
            '--iconv=utf-8,utf-8-mac'
        )
    fi
    rsync "${flags[@]}" "$@"
    return 0
}

koopa::rsync_cloud() { # {{{1
    # """
    # Rsync to cloud object storage buckets, such as AWS.
    # @note Updated 2020-12-31.
    # """
    local flags
    koopa::assert_has_args "$#"
    koopa::assert_is_installed rsync
    flags=(
        # '--exclude=bam'
        # '--exclude=cram'
        # '--exclude=fastq'
        # '--exclude=sam'
        '--exclude=.Rproj.user'
        '--exclude=.git'
        '--exclude=.gitignore'
        '--exclude=work'
        '--human-readable'
        '--no-links'
        '--progress'
        '--recursive'
        '--size-only'
        '--stats'
        '--verbose'
        '--rsync-path="sudo rsync"'
    )
    rsync "${flags[@]}" "$@"
    return 0
}

# FIXME REWORK, WRAPPING KOOPA::RSYNC
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
