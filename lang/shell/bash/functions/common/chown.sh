#!/usr/bin/env bash

koopa_chown() {
    # """
    # Hardened version of coreutils chown (change ownership).
    # @note Updated 2021-10-29.
    # """
    local app chown dict pos
    declare -A app=(
        [chown]="$(koopa_locate_chown)"
    )
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--dereference' | \
            '-H')
                dict[dereference]=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict[dereference]=0
                shift 1
                ;;
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
        chown=("${app[sudo]}" "${app[chown]}")
    else
        chown=("${app[chown]}")
    fi
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chown+=('-R')
    fi
    if [[ "${dict[dereference]}" -eq 0 ]]
    then
        chown+=('-h')
    fi
    "${chown[@]}" "$@"
    return 0
}
