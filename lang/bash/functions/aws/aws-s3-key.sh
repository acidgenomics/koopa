#!/usr/bin/env bash

_koopa_aws_s3_key() {
    # """
    # Return the file key for an AWS S3 URI.
    # @note Updated 2023-11-03.
    #
    # @examples
    # > _koopa_aws_s3_key 's3://koopa.acidgenomics.com/install'
    # # install
    # """
    local string
    _koopa_assert_has_args "$#"
    _koopa_is_aws_s3_uri "$@" || return 1
    string="$( \
        _koopa_sub \
            --pattern='^s3://([^/]+)/(.+)$' \
            --regex \
            --replacement='\2' \
            "$@" \
    )"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
