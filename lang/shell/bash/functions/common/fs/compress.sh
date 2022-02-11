#!/usr/bin/env bash

koopa::tar_multiple_dirs() { # {{{1
    # """
    # Compress (tar) multiple directories in a single call.
    # @note Updated 2022-02-04.
    # """
    local app dict dir dirs pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [tar]="$(koopa::locate_tar)"
    )
    declare -A dict=(
        [delete]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--delete')
                dict[delete]=1
                shift 1
                ;;
            '--no-delete' | \
            '--keep')
                dict[delete]=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_is_dir "$@"
    readarray -t dirs <<< "$(koopa::realpath "$@")"
    (
        for dir in "${dirs[@]}"
        do
            local bn
            bn="$(koopa::basename "$dir")"
            koopa::alert "Compressing '${dir}'."
            koopa::cd "$(koopa::dirname "$dir")"
            "${app[tar]}" -czf "${bn}.tar.gz" "${bn}/"
            [[ "${dict[delete]}" -eq 1 ]] && koopa::rm "$dir"
        done
    )
    return 0
}
