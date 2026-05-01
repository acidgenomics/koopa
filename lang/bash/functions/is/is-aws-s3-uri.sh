#!/usr/bin/env bash

_koopa_is_aws_s3_uri() {
    # """
    # Does the input contain an AWS S3 URI?
    # @note Updated 2023-10-20.
    #
    # @examples
    # _koopa_is_aws_s3_uri 's3://example/'
    # """
    local pattern string
    _koopa_assert_has_args "$#"
    pattern='s3://'
    for string in "$@"
    do
        _koopa_str_detect_fixed \
            --pattern="$pattern" \
            --string="$string" \
        || return 1
    done
    return 0
}
