#!/usr/bin/env bash

koopa_chgrp() {
    # """
    # Hardened version of coreutils chgrp (change user group).
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    local -a chgrp pos
    app['chgrp']="$(koopa_locate_chgrp)"
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
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        chgrp=('koopa_sudo' "${app['chgrp']}")
    else
        chgrp=("${app['chgrp']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${chgrp[@]}" "$@"
    return 0
}
