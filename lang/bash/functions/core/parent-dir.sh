#!/usr/bin/env bash

_koopa_parent_dir() {
    # """
    # Get the parent directory path.
    # @note Updated 2023-04-05.
    #
    # This requires file to exist and resolves symlinks.
    # """
    local -A app dict
    local -a pos
    local file
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cd_tail']=''
    dict['n']=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--num='*)
                dict['n']="${1#*=}"
                shift 1
                ;;
            '--num' | \
            '-n')
                dict['n']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    [[ "${dict['n']}" -ge 1 ]] || dict['n']=1
    if [[ "${dict['n']}" -ge 2 ]]
    then
        dict['n']="$((dict[n]-1))"
        dict['cd_tail']="$( \
            printf "%${dict['n']}s" \
            | "${app['sed']}" 's| |/..|g' \
        )"
    fi
    for file in "$@"
    do
        local parent
        [[ -e "$file" ]] || return 1
        parent="$(_koopa_dirname "$file")"
        parent="${parent}${dict['cd_tail']}"
        parent="$(_koopa_cd "$parent" && pwd -P)"
        _koopa_print "$parent"
    done
    return 0
}
