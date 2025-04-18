#!/usr/bin/env bash

koopa_rm() {
    # """
    # Remove files/directories quietly with GNU rm.
    # @note Updated 2025-04-18.
    # """
    local -A app bool
    local -a pos rm rm_args
    app['rm']="$(koopa_locate_rm --allow-system --realpath)"
    bool['sudo']=0
    bool['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--quiet' | \
            '-q')
                bool['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                bool['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                bool['verbose']=1
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
    [[ "${bool['verbose']}" -eq 1 ]] && rm_args+=('-v')
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        rm+=('koopa_sudo' "${app['rm']}")
    else
        rm=("${app['rm']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}
