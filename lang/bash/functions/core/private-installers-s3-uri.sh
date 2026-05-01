#!/usr/bin/env bash

_koopa_private_installers_s3_uri() {
    # """
    # Private installers AWS S3 URI.
    # @note Updated 2023-03-14.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_print 's3://private.koopa.acidgenomics.com/installers'
}
