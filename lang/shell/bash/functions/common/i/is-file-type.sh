#!/usr/bin/env bash

koopa_is_file_type() {
    # """
    # Does the input exist and match a file type extension?
    # @note Updated 2022-02-17.
    #
    # @usage koopa_is_file_type --ext=EXT FILE...
    #
    # @examples
    # > koopa_is_file_type --ext='csv' 'aaa.csv' 'bbb.csv'
    # """
    local dict file pos
    declare -A dict=(
        [ext]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--ext='*)
                dict[ext]="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict[ext]="${2:?}"
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
    koopa_assert_is_set '--ext' "${dict[ext]}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        koopa_str_detect_regex \
            --string="$file" \
            --pattern="\.${dict[ext]}$" \
        || return 1
    done
    return 0
}

