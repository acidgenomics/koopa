#!/usr/bin/env bash

koopa_parent_dir() {
    # """
    # Get the parent directory path.
    # @note Updated 2021-09-21.
    #
    # This requires file to exist and resolves symlinks.
    # """
    local app dict file parent pos
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [cd_tail]=''
        [n]=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--num='*)
                dict[n]="${1#*=}"
                shift 1
                ;;
            '--num' | \
            '-n')
                dict[n]="${2:?}"
                shift 2
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
    [[ "${dict[n]}" -ge 1 ]] || dict[n]=1
    if [[ "${dict[n]}" -ge 2 ]]
    then
        dict[n]="$((dict[n]-1))"
        dict[cd_tail]="$( \
            printf "%${dict[n]}s" \
            | "${app[sed]}" 's| |/..|g' \
        )"
    fi
    for file in "$@"
    do
        [[ -e "$file" ]] || return 1
        parent="$(koopa_dirname "$file")"
        parent="${parent}${dict[cd_tail]}"
        parent="$(koopa_cd "$parent" && pwd -P)"
        koopa_print "$parent"
    done
    return 0
}
