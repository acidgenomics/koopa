#!/usr/bin/env bash

koopa_rsync() {
    # """
    # GNU rsync wrapper.
    # @note Updated 2022-04-04.
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
    local app dict rsync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [rsync]="$(koopa_locate_rsync)"
    )
    declare -A dict=(
        [source_dir]=''
        [target_dir]=''
    )
    rsync_args=(
        '--human-readable'
        '--one-file-system'
        '--progress'
        '--protect-args'
        '--recursive'
        '--stats'
        '--verbose'
    )
    if koopa_is_macos
    then
        rsync_args+=(
            '--iconv=utf-8,utf-8-mac'
        )
    fi
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--exclude='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--exclude')
                rsync_args+=("--exclude=${2:?}")
                shift 2
                ;;
            '--filter='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--filter')
                rsync_args+=("--filter=${2:?}")
                shift 2
                ;;
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--archive' | \
            '--delete' | \
            '--delete-before' | \
            '--dry-run')
                rsync_args+=("$1")
                shift 1
                ;;
            '--sudo')
                rsync_args+=('--rsync-path' 'sudo rsync')
                shift 1
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    if [[ -d "${dict[source_dir]}" ]]
    then
        dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    fi
    if [[ -d "${dict[target_dir]}" ]]
    then
        dict[target_dir]="$(koopa_realpath "${dict[target_dir]}")"
    fi
    dict[source_dir]="$(koopa_strip_trailing_slash "${dict[source_dir]}")"
    dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
    rsync_args+=("${dict[source_dir]}/" "${dict[target_dir]}/")
    "${app[rsync]}" "${rsync_args[@]}"
    return 0
}
