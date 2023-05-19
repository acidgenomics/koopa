#!/usr/bin/env bash

koopa_koopa_url() {
    # """
    # Koopa URL.
    # @note Updated 2022-08-23.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print 'https://koopa.acidgenomics.com'
    return 0
}
