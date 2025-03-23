#!/usr/bin/env bash

koopa_move_into_dated_dirs_by_timestamp() {
    # """
    # Move into dated directories by timestamp.
    # @note Updated 2023-03-26.
    # """
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        local subdir
        subdir="$(koopa_stat_modified --format='%Y/%m/%d' "$file")"
        koopa_mv --target-directory="$subdir" "$file"
    done
    return 0
}
