#!/usr/bin/env bash

koopa_koopa_url() {
    # """
    # Koopa URL.
    # @note Updated 2021-06-07.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-url'
    return 0
}
