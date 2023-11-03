#!/usr/bin/env bash

koopa_aws_s3_bucket() {
    # """
    # Return the bucket name for an AWS S3 URI.
    # @note Updated 2023-11-03.
    #
    # @examples
    # > koopa_aws_s3_bucket 's3://koopa.acidgenomics.com/install'
    # # koopa.acidgenomics.com
    # """
    local string
    koopa_assert_has_args "$#"
    koopa_is_aws_s3_uri "$@" || return 1
    string="$( \
        koopa_sub \
            --pattern='^s3://([^/]+)/(.+)$' \
            --regex \
            --replacement='\1' \
            "$@" \
    )"
    [[ -n "$string" ]] || return 1
    koopa_print "$string"
    return 0
}
