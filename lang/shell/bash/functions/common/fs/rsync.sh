#!/usr/bin/env bash

# FIXME Rework using dict approach.
koopa::clone() { # {{{1
    # """
    # Clone files using rsync (with saner defaults).
    # @note Updated 2020-12-31.
    # """
    local rsync_args source_dir target_dir
    koopa::assert_has_no_flags "$@"
    koopa::assert_has_args_eq "$#" 2
    source_dir="${1:?}"
    target_dir="${2:?}"
    koopa::assert_is_dir "$source_dir" "$target_dir"
    rsync_args=(
        '--archive'
        '--delete-before'
    )
    source_dir="$(koopa::realpath "$source_dir")"
    source_dir="$(koopa::strip_trailing_slash "$source_dir")"
    target_dir="$(koopa::realpath "$target_dir")"
    target_dir="$(koopa::strip_trailing_slash "$target_dir")"
    koopa::dl \
        'Source' "$source_dir" \
        'Target' "$target_dir"
    koopa::rsync "${rsync_args[@]}" "${source_dir}/" "${target_dir}/"
    return 0
}

# FIXME Rework using app/dict approach.
# NOTE Consider checking for trailing slashes on directories.
koopa::rsync() { # {{{1
    # """
    # GNU rsync wrapper.
    # @note Updated 2021-05-20.
    #
    # Useful arguments:
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
    local rsync rsync_args
    koopa::assert_has_args_ge "$#" 2
    rsync="$(koopa::locate_rsync)"
    rsync_args=(
        '--human-readable'
        '--progress'
        '--protect-args'
        '--recursive'
        '--stats'
        '--verbose'
    )
    if koopa::is_macos
    then
        rsync_args+=(
            '--iconv=utf-8,utf-8-mac'
        )
    fi
    "$rsync" "${rsync_args[@]}" "$@"
    return 0
}

koopa::rsync_cloud() { # {{{1
    # """
    # Rsync to cloud object storage buckets, such as AWS.
    # @note Updated 2021-10-29.
    # """
    local rsync_args
    koopa::assert_has_no_flags "$@"
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    rsync_args=(
        '--exclude' '.Rproj.user'
        '--exclude' '.git'
        '--exclude' '.gitignore'
        '--exclude' 'work'
        '--no-links'
        '--rsync-path' 'sudo rsync'
        '--size-only'
    )
    koopa::rsync "${rsync_args[@]}" "$@"
    return 0
}

koopa::rsync_ignore() { # {{{1
    # """
    # Run rsync with automatic ignore.
    # @note Updated 2021-05-08.
    #
    # @seealso
    # https://stackoverflow.com/questions/13713101/
    # """
    local ignore_global rsync_args
    koopa::assert_has_no_flags "$@"
    koopa::assert_has_args_eq "$#" 2
    rsync_args=(
        # > '--exclude=.*/'
        # > '--exclude=/.git'
        # > '--filter=:- .gitignore'
        '--archive'
        '--exclude=.*'
        '--filter=dir-merge,- .gitignore'
    )
    ignore_global="${HOME}/.gitignore"
    if [[ -f "$ignore_global" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${ignore_global}")
    fi
    koopa::rsync "${rsync_args[@]}" "$@"
    return 0
}
