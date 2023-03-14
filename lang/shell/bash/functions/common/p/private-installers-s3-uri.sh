#!/usr/bin/env bash

koopa_private_installers_s3_uri() {
    # """
    # Private installers AWS S3 URI.
    # @note Updated 2023-03-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print 's3://private.koopa.acidgenomics.com/installers'
}
