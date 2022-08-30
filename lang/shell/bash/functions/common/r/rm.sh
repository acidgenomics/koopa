#!/usr/bin/env bash

koopa_rm() {
    # """
    # Remove files/directories quietly with GNU rm.
    # @note Updated 2022-08-29.
    # """
    local app dict pos rm rm_args
    declare -A app
    app['rm']="$(koopa_locate_rm --allow-missing)"
    if [[ ! -x "${app['rm']}" ]]
    then
        if [[ -x '/usr/bin/rm' ]]
        then
            app['rm']='/usr/bin/rm'
        elif [[ -x '/bin/rm' ]]
        then
            app['rm']='/bin/rm'
        fi
    fi
    [[ -x "${app['rm']}" ]] || return 1
    declare -A dict=(
        ['sudo']=0
    )
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
    koopa_assert_has_args "$#"
    rm_args=('-fr')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        rm+=("${app['sudo']}" "${app['rm']}")
    else
        rm=("${app['rm']}")
    fi
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}
