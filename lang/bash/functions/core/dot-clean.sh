#!/usr/bin/env bash

_koopa_dot_clean() {
    # """
    # Clean up dot files recursively inside a directory.
    # @note Updated 2023-06-27.
    # """
    local -A app dict
    local -a basenames cruft files
    local i
    _koopa_assert_has_args_eq "$#" 1
    dict['prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    if _koopa_is_macos
    then
        app['dot_clean']="$(_koopa_macos_locate_dot_clean)"
        _koopa_assert_is_executable "${app['dot_clean']}"
        # Can use '-v' flag here for increased verbosity.
        "${app['dot_clean']}" "${dict['prefix']}"
    fi
    readarray -t files <<< "$( \
        _koopa_find \
            --hidden \
            --pattern='.*' \
            --prefix="${dict['prefix']}" \
    )"
    if _koopa_is_array_empty "${files[@]}"
    then
        return 0
    fi
    cruft=()
    readarray -t basenames <<< "$(_koopa_basename "${files[@]}")"
    for i in "${!files[@]}"
    do
        local basename file
        file="${files[$i]}"
        [[ -e "$file" ]] || continue
        basename="${basenames[$i]}"
        case "$basename" in
            '.AppleDouble' | \
            '.DS_Store' | \
            '.Rhistory' | \
            '.lacie' | \
            '._'*)
                _koopa_rm --verbose "$file"
                ;;
            *)
                cruft+=("$file")
                ;;
        esac
    done
    if _koopa_is_array_non_empty "${cruft[@]:-}"
    then
        _koopa_alert_note "Dot files remaining in '${dict['prefix']}'."
        _koopa_print "${cruft[@]}"
        return 1
    fi
    return 0
}
