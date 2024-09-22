#!/usr/bin/env bash

koopa_rm() {
    # """
    # Remove files/directories quietly with GNU rm.
    # @note Updated 2024-09-22.
    # """
    local -A app dict
    local -a pos rm rm_args
    app['rm']="$(koopa_locate_rm --allow-system --realpath)"
    dict['sudo']=0
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    rm_args=('-f' '-r')
    [[ "${dict['verbose']}" -eq 1 ]] && rm_args+=('-v')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        rm+=('koopa_sudo' "${app['rm']}")
    else
        rm=("${app['rm']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}
