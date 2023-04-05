#!/usr/bin/env bash

koopa_test_find_files_by_ext() {
    # """
    # Find relevant test files by extension.
    # @note Updated 2022-10-07.
    #
    # @examples
    # > koopa_test_find_files_by_ext 'sh'
    # > koopa_test_find_files_by_ext 'py'
    # > koopa_test_find_files_by_ext 'R'
    # """
    local all_files dict
    koopa_assert_has_args "$#"
    local -A dict=(
        ['ext']="${1:?}"
    )
    dict['pattern']="\.${dict['ext']}$"
    readarray -t all_files <<< "$(koopa_test_find_files)"
    dict['files']="$( \
        koopa_print "${all_files[@]}" \
        | koopa_grep \
            --pattern="${dict['pattern']}" \
            --regex \
        || true \
    )"
    if [[ -z "${dict['files']}" ]]
    then
        koopa_stop "Failed to find test files with extension '${dict['ext']}'."
    fi
    koopa_print "${dict['files']}"
    return 0
}
