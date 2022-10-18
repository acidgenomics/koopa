#!/usr/bin/env bash

koopa_can_install_binary() {
    # """
    # Can the current user install and/or push a koopa binary?
    # @note Updated 2022-10-18.
    # 
    # Currently requires access to our private S3 bucket.
    # """
    [[ -n "${KOOPA_AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]]
}
