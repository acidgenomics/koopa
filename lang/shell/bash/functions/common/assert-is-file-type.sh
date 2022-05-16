#!/usr/bin/env bash

koopa_assert_is_file_type() {
    # """
    # Assert that input matches a specified file type.
    # @note Updated 2022-02-17.
    #
    # @usage
    # > koopa_assert_is_file_type --string=STRING --pattern=PATTERN
    # """
    koopa_assert_has_args "$#"
    if ! koopa_is_file_type "$@"
    then
        koopa_stop 'Input does not match expected file type extension.'
    fi
    return 0
}
