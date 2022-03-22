#!/usr/bin/env bash

koopa_clone() { # {{{1
    # """
    # Clone files using rsync (with saner defaults).
    # @note Updated 2022-03-01.
    # """
    local dict rsync_args
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_has_no_flags "$@"
    declare -A dict=(
        [source_dir]="${1:?}"
        [target_dir]="${2:?}"
    )
    koopa_assert_is_dir "${dict[source_dir]}" "${dict[target_dir]}"
    dict[source_dir]="$( \
        koopa_realpath "${dict[source_dir]}" \
        | koopa_strip_trailing_slash \
    )"
    dict[target_dir]="$( \
        koopa_realpath "${dict[target_dir]}" \
        | koopa_strip_trailing_slash \
    )"
    koopa_dl \
        'Source' "${dict[source_dir]}" \
        'Target' "${dict[target_dir]}"
    rsync_args=(
        '--archive'
        '--delete-before'
    )
    koopa_rsync "${rsync_args[@]}" \
        "${dict[source_dir]}/" \
        "${dict[target_dir]}/"
    return 0
}

koopa_rsync() { # {{{1
    # """
    # GNU rsync wrapper.
    # @note Updated 2022-03-01.
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
    local app dict pos rsync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [rsync]="$(koopa_locate_rsync)"
    )
    declare -A dict
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
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo')
                rsync_args+=('--rsync-path' 'sudo rsync')
                shift 1
                ;;
            '--archive' | \
            '--delete' | \
            '--delete-before' | \
            '--dry-run' | \
            '--exclude='* | \
            '--filter='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_has_no_flags "$@"
    dict[source_dir]="${1:?}"
    dict[target_dir]="${2:?}"
    if [[ -d "${source_dir]}" ]]
    then
        dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    fi
    if [[ -d "${target_dir]}" ]]
    then
        dict[target_dir]="$(koopa_realpath "${dict[target_dir]}")"
    fi
    dict[source_dir]="$(koopa_strip_trailing_slash "${dict[source_dir]}")"
    dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
    "${app[rsync]}" "${rsync_args[@]}" \
        "${dict[source_dir]}/" \
        "${dict[target_dir]}/"
    return 0
}

koopa_rsync_ignore() { # {{{1
    # """
    # Run rsync with automatic ignore.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - https://stackoverflow.com/questions/13713101/
    # """
    local dict rsync_args
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_has_no_flags "$@"
    declare -A dict=(
        [ignore_local]='.gitignore'
        [ignore_global]="${HOME}/.gitignore"
    )
    rsync_args=(
        '--archive'
        '--exclude=.*'
    )
    if [[ -f "${dict[ignore_local]}" ]]
    then
        rsync_args+=(
            "--filter=dir-merge,- ${dict[ignore_local]}"
        )
    fi
    if [[ -f "${dict[ignore_global]}" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${dict[ignore_global]}")
    fi
    koopa_rsync "${rsync_args[@]}" "$@"
    return 0
}
