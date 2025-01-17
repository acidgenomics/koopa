#!/usr/bin/env bash

koopa_dot_clean() {
    # """
    # Clean up dot files recursively inside a directory.
    # @note Updated 2023-06-27.
    # """
    local -A app dict
    local -a basenames cruft files
    local i
    koopa_assert_has_args_eq "$#" 1
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    if koopa_is_macos
    then
        app['dot_clean']="$(koopa_macos_locate_dot_clean)"
        koopa_assert_is_executable "${app['dot_clean']}"
        # Can use '-v' flag here for increased verbosity.
        "${app['dot_clean']}" "${dict['prefix']}"
    fi
    readarray -t files <<< "$( \
        koopa_find \
            --hidden \
            --pattern='.*' \
            --prefix="${dict['prefix']}" \
    )"
    if koopa_is_array_empty "${files[@]}"
    then
        return 0
    fi
    cruft=()
    readarray -t basenames <<< "$(koopa_basename "${files[@]}")"
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
                koopa_rm --verbose "$file"
                ;;
            *)
                cruft+=("$file")
                ;;
        esac
    done
    if koopa_is_array_non_empty "${cruft[@]:-}"
    then
        koopa_alert_note "Dot files remaining in '${dict['prefix']}'."
        koopa_print "${cruft[@]}"
        return 1
    fi
    return 0
}
