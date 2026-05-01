#!/usr/bin/env bash

_koopa_version_pattern() {
    # """
    # Version pattern.
    # @note Updated 2022-02-27.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([+a-z])?([0-9]+)?'
    return 0
}
