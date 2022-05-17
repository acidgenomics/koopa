#!/usr/bin/env bash

koopa_chmod() {
    # """
    # Hardened version of coreutils chmod (change file mode bits).
    # @note Updated 2022-02-17.
    # """
    local app chmod dict pos
    declare -A app=(
        [chmod]="$(koopa_locate_chmod)"
    )
    declare -A dict=(
        [recursive]=0
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--recursive' | \
            '-R')
                dict[recursive]=1
                shift 1
                ;;
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
    koopa_assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        chmod=("${app[sudo]}" "${app[chmod]}")
    else
        chmod=("${app[chmod]}")
    fi
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    "${chmod[@]}" "$@"
    return 0
}
