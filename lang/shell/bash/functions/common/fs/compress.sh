#!/usr/bin/env bash

# FIXME Add option to delete input directories with '--delete' flag?

koopa::tar_multiple_dirs() { # {{{1
    # """
    # Compress (tar) multiple directories in a single call.
    # @note Updated 2022-02-04.
    # """
    local app dir dirs
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    declare -A app=(
        [tar]="$(koopa::locate_tar)"
    )
    readarray -t dirs <<< "$(koopa::realpath "$@")"
    (
        for dir in "${dirs[@]}"
        do
            local bn
            bn="$(koopa::basename "$dir")"
            koopa::alert "Compressing '${dir}'."
            koopa::cd "$(koopa::dirname "$dir")"
            "${app[tar]}" -czf "${bn}.tar.gz" "${bn}/"
        done
    )
    return 0
}
