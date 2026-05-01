#!/usr/bin/env bash

_koopa_has_monorepo() {
    # """
    # Does the current user have a monorepo?
    # @note Updated 2020-07-03.
    # """
    [[ -d "$(_koopa_monorepo_prefix)" ]]
}
