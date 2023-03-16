#!/usr/bin/env bash

koopa_can_install_binary() {
    # """
    # Can the current user install and/or push a koopa binary?
    # @note Updated 2023-03-15.
    # 
    # Currently requires access to our private S3 bucket.
    # """
    [[ -n "${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]]
}
