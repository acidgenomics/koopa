#!/usr/bin/env bash

_koopa_assert_has_monorepo() {
    # """
    # Assert that the user has a git monorepo.
    # @note Updated 2020-07-03.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_has_monorepo
    then
        _koopa_stop "No monorepo at '$(_koopa_monorepo_prefix)'."
    fi
    return 0
}
