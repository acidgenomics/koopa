#!/usr/bin/env bash

koopa_insert_at_line_number() {
    # """
    # Insert a line of text into a file at a desired line number.
    # @note Updated 2022-06-22.
    # """
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    declare -A dict=(
        [file]=''
        [line_number]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--line-number='*)
                dict[line_number]="${1#*=}"
                shift 1
                ;;
            '--line-number')
                dict[line_number]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--line-number' "${dict[line_number]}" \
        '--string' "${dict[string]}"
    koopa_assert_is_file "${dict[file]}"
    dict[perl_cmd]="print '${dict[string]}' if \$. == ${dict[line_number]}"
    "${app[perl]}" -i -l -p -e "${dict[perl_cmd]}" "${dict[file]}"
    return 0
}
