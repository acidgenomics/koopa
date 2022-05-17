#!/usr/bin/env bash

koopa_mkdir() {
    # """
    # Create directories with parents automatically.
    # @note Updated 2021-10-29.
    # """
    local app dict mkdir mkdir_args pos
    declare -A app=(
        [mkdir]="$(koopa_locate_mkdir)"
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
    mkdir_args=('-p')
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        mkdir=("${app[sudo]}" "${app[mkdir]}")
    else
        mkdir=("${app[mkdir]}")
    fi
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}
