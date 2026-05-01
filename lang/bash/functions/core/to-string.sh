#!/usr/bin/env bash

_koopa_to_string() {
    # """
    # Paste arguments to a comma separated string.
    # @note Updated 2023-03-18.
    #
    # @examples
    # > _koopa_to_string 'aaa' 'bbb'
    # # aaa, bbb
    # """
    _koopa_assert_has_args "$#"
    _koopa_paste --sep=', ' "$@"
    return 0
}
