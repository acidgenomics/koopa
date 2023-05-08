#!/usr/bin/env bash

koopa_can_push_binary() {
    # """
    # Can the current user push a koopa binary?
    # @note Updated 2023-05-08.
    # """
    [[ -n "${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    koopa_can_install_binary || return 1
    return 0
}

