#!/usr/bin/env bash

koopa_current_gencode_version() {
    # """
    # Current GENCODE version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_gencode_version
    # # 39
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
        [cut]="$(koopa_locate_cut)"
        [grep]="$(koopa_locate_grep)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [organism]="${1:-}"
    )
    [[ -z "${dict[organism]}" ]] && dict[organism]='Homo sapiens'
    case "${dict[organism]}" in
        'Homo sapiens' | \
        'human')
            dict[short_name]='human'
            dict[pattern]='Release [0-9]+'
            ;;
        'Mus musculus' | \
        'mouse')
            dict[short_name]='mouse'
            dict[pattern]='Release M[0-9]+'
            ;;
        *)
            koopa_stop "Unsupported organism: '${dict[organism]}'."
            ;;
    esac
    dict[base_url]='https://www.gencodegenes.org'
    dict[url]="${dict[base_url]}/${dict[short_name]}/"
    dict[str]="$( \
        koopa_parse_url "${dict[url]}" \
        | koopa_grep \
            --only-matching \
            --pattern="${dict[pattern]}" \
            --regex \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
