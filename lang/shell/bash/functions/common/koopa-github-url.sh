#!/usr/bin/env bash

koopa_koopa_github_url() {
    # """
    # Koopa GitHub URL.
    # @note Updated 2021-06-07.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-github-url'
    return 0
}
