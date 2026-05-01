#!/usr/bin/env bash

_koopa_unlink_in_dir() {
    # """
    # Unlink multiple symlinks in a directory.
    # @note Updated 2023-04-05.
    # """
    local -A dict
    local -a names pos
    local name
    _koopa_assert_has_args "$#"
    dict['allow_missing']=0
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--allow-missing')
                dict['allow_missing']=1
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
    _koopa_assert_is_set '--prefix' "${dict['prefix']}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    names=("$@")
    for name in "${names[@]}"
    do
        local file
        file="${dict['prefix']}/${name}"
        if [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            if [[ -L "$file" ]]
            then
                # > _koopa_alert "Unlinking '${file}'."
                _koopa_rm "$file"
            fi
        else
            _koopa_assert_is_symlink "$file"
            # > _koopa_alert "Unlinking '${file}'."
            _koopa_rm "$file"
        fi
    done
    return 0
}
