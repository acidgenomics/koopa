#!/usr/bin/env bash

koopa_relink() {
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2023-04-05.
    # """
    local -A dict
    local -a ln pos rm sudo
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict['sudo']=1
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
    koopa_assert_has_args_eq "$#" 2
    ln=('koopa_ln')
    rm=('koopa_rm')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        ln+=('--sudo')
        rm+=('--sudo')
    fi
    dict['source_file']="${1:?}"
    dict['dest_file']="${2:?}"
    [[ -e "${dict['source_file']}" ]] || return 0
    [[ -L "${dict['dest_file']}" ]] && return 0
    "${rm[@]}" "${dict['dest_file']}"
    "${ln[@]}" "${dict['source_file']}" "${dict['dest_file']}"
    return 0
}
