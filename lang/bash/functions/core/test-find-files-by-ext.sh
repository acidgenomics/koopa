#!/usr/bin/env bash

_koopa_test_find_files_by_ext() {
    # """
    # Find relevant test files by extension.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > _koopa_test_find_files_by_ext 'sh'
    # > _koopa_test_find_files_by_ext 'py'
    # > _koopa_test_find_files_by_ext 'R'
    # """
    local -A dict
    local -a all_files
    _koopa_assert_has_args "$#"
    dict['ext']="${1:?}"
    dict['pattern']="\.${dict['ext']}$"
    readarray -t all_files <<< "$(_koopa_test_find_files)"
    dict['files']="$( \
        _koopa_print "${all_files[@]}" \
        | _koopa_grep \
            --pattern="${dict['pattern']}" \
            --regex \
        || true \
    )"
    if [[ -z "${dict['files']}" ]]
    then
        _koopa_stop "Failed to find test files with extension '${dict['ext']}'."
    fi
    _koopa_print "${dict['files']}"
    return 0
}
