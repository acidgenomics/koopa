#!/usr/bin/env bash

_koopa_koopa_url() {
    # """
    # Koopa URL.
    # @note Updated 2022-08-23.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_print 'https://koopa.acidgenomics.com'
    return 0
}
