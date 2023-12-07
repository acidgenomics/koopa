#!/usr/bin/env bash

koopa_can_push_binary() {
    # """
    # Can the current user push a koopa binary?
    # @note Updated 2023-12-07.
    # """
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]] || return 1
    [[ -n "${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    return 0
}
