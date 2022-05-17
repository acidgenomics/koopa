#!/usr/bin/env bash

koopa_assert_has_monorepo() {
    # """
    # Assert that the user has a git monorepo.
    # @note Updated 2020-07-03.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_has_monorepo
    then
        koopa_stop "No monorepo at '$(koopa_monorepo_prefix)'."
    fi
    return 0
}
