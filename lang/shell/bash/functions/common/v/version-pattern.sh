#!/usr/bin/env bash

koopa_version_pattern() {
    # """
    # Version pattern.
    # @note Updated 2022-02-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([+a-z])?([0-9]+)?'
    return 0
}
