#!/usr/bin/env bash

koopa_can_push_binary() {
    # """
    # Can the current user push a koopa binary?
    # @note Updated 2023-12-07.
    # """
    local -A app
    koopa_has_private_access || return 1
    koopa_can_build_binary || return 1
    [[ -n "${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    app['aws']="$(koopa_locate_aws --allow-missing)"
    [[ -x "${app['aws']}" ]] || return 1
    return 0
}
