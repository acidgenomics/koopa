#!/usr/bin/env bash

_koopa_touch() {
    # """
    # Touch (create) a file on disk.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    local -a mkdir pos touch
    _koopa_assert_has_args "$#"
    app['touch']="$(_koopa_locate_touch --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
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
    mkdir=('_koopa_mkdir')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir+=('--sudo')
        touch=('_koopa_sudo' "${app['touch']}")
    else
        touch=("${app['touch']}")
    fi
    for file in "$@"
    do
        local dn
        if [[ -e "$file" ]]
        then
            _koopa_assert_is_not_dir "$file"
            _koopa_assert_is_not_symlink "$file"
        fi
        # Automatically create parent directory, if necessary.
        dn="$(_koopa_dirname "$file")"
        if [[ ! -d "$dn" ]] && \
            _koopa_str_detect_fixed \
                --string="$dn" \
                --pattern='/'
        then
            "${mkdir[@]}" "$dn"
        fi
        "${touch[@]}" "$file"
    done
    return 0
}
