#!/usr/bin/env bash

koopa_chmod() {
    # """
    # Hardened version of coreutils chmod (change file mode bits).
    # @note Updated 2025-04-15.
    # """
    local -A app bool
    local -a chmod pos
    app['chmod']="$(koopa_locate_chmod)"
    bool['recursive']=0
    bool['sudo']=0
    bool['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--recursive' | \
            '-R')
                bool['recursive']=1
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
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        chmod=('koopa_sudo' "${app['chmod']}")
    else
        chmod=("${app['chmod']}")
    fi
    if [[ "${bool['recursive']}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        chmod+=('-v')
    fi
    koopa_assert_is_executable "${app[@]}"
    "${chmod[@]}" "$@"
    return 0
}
