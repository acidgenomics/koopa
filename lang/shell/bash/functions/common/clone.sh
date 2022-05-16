#!/usr/bin/env bash

koopa_clone() {
    # """
    # Clone files using rsync (with saner defaults).
    # @note Updated 2022-04-04.
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
        'Source dir' "${dict[source_dir]}" \
        'Target dir' "${dict[target_dir]}"
    rsync_args=(
        '--archive'
        '--delete-before'
        "--source-dir=${dict[source_dir]}"
        "--target-dir=${dict[target_dir]}"
    )
    koopa_rsync "${rsync_args[@]}"
    return 0
}
