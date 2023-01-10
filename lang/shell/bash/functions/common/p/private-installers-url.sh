#!/usr/bin/env bash

koopa_private_installers_url() {
    # """
    # Koopa private installers URL.
    # @note Updated 2022-01-10.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print 's3://private.koopa.acidgenomics.com/installers'
}
