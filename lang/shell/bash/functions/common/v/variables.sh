#!/usr/bin/env bash

koopa_variables() {
    # """
    # Edit koopa variables.
    # @note Updated 2022-05-16.
    # """
    koopa_assert_has_no_args "$#"
    "${EDITOR:?}" "$(koopa_include_prefix)/variables.txt"
    return 0
}
