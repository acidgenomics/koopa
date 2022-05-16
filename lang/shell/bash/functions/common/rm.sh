#!/usr/bin/env bash

koopa_rm() {
    # """
    # Remove files/directories quietly with GNU rm.
    # @note Updated 2021-09-21.
    # """
    local app dict pos rm rm_args
    declare -A app=(
        [rm]="$(koopa_locate_rm)"
    )
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
    koopa_assert_has_args "$#"
    rm_args=('-fr')
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        rm+=("${app[sudo]}" "${app[rm]}")
    else
        rm=("${app[rm]}")
    fi
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}
