#!/usr/bin/env bash

koopa_can_install_binary() {
    # """
    # Can the current user install and/or push a koopa binary?
    # @note Updated 2024-06-14.
    #
    # Currently requires access to our private S3 bucket.
    # """
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]] && return 1
    koopa_has_private_access || return 1
    koopa_can_push_binary && return 1
    return 0
}
