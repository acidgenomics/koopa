#!/usr/bin/env bash

koopa_has_monorepo() {
    # """
    # Does the current user have a monorepo?
    # @note Updated 2020-07-03.
    # """
    [[ -d "$(koopa_monorepo_prefix)" ]]
}
