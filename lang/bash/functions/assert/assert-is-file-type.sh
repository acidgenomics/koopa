#!/usr/bin/env bash

_koopa_assert_is_file_type() {
    # """
    # Assert that input matches a specified file type.
    # @note Updated 2022-02-17.
    #
    # @usage
    # > _koopa_assert_is_file_type --string=STRING --pattern=PATTERN
    # """
    _koopa_assert_has_args "$#"
    if ! _koopa_is_file_type "$@"
    then
        _koopa_stop 'Input does not match expected file type extension.'
    fi
    return 0
}
