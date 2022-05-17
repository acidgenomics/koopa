#!/usr/bin/env bash

koopa_init_dir() {
    # """
    # Initialize (create) a directory and return the real path on disk.
    # @note Updated 2021-11-04.
    # """
    local dict mkdir pos
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    koopa_assert_has_args_eq "$#" 1
    dict[dir]="${1:?}"
    if koopa_str_detect_regex \
        --string="${dict[dir]}" \
        --pattern='^~'
    then
        dict[dir]="$( \
            koopa_sub \
                --pattern='^~' \
                --replacement="${HOME:?}" \
                "${dict[dir]}" \
        )"
    fi
    mkdir=('koopa_mkdir')
    [[ "${dict[sudo]}" -eq 1 ]] && mkdir+=('--sudo')
    if [[ ! -d "${dict[dir]}" ]]
    then
        "${mkdir[@]}" "${dict[dir]}"
    fi
    dict[realdir]="$(koopa_realpath "${dict[dir]}")"
    koopa_print "${dict[realdir]}"
    return 0
}
