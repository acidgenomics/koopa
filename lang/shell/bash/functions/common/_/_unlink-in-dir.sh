#!/usr/bin/env bash

__koopa_unlink_in_dir() {
    # """
    # Unlink multiple symlinks in a directory.
    # @note Updated 2022-08-01.
    # """
    local dict file files name names pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [prefix]=''
        [quiet]=0
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
            # Flags ------------------------------------------------------------
            '--quiet')
                dict[quiet]=1
                shift 1
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
    for name in "${names[@]}"
    do
        files+=("${dict[prefix]}/${name}")
    done
    if [[ "${dict[quiet]}" -eq 1 ]]
    then
        koopa_rm "${files[@]}"
    else
        for file in "${files[@]}"
        do
            koopa_alert "Unlinking '${file}'."
            koopa_rm "$file"
        done
    fi
    return 0
}
