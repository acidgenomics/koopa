#!/usr/bin/env bash

__koopa_unlink_in_dir() {
    # """
    # Unlink multiple symlinks in a directory.
    # @note Updated 2022-04-07.
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
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
    koopa_assert_has_args "$#"
    koopa_assert_is_set '--prefix' "${dict[prefix]}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    names=("$@")
    files=()
    for i in "${!names[@]}"
    do
        files+=("${dict[prefix]}/${names[$i]}")
    done
    koopa_rm "${files[@]}"
    return 0
}
