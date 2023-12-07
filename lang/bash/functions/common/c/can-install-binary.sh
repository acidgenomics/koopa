#!/usr/bin/env bash

koopa_can_install_binary() {
    # """
    # Can the current user install and/or push a koopa binary?
    # @note Updated 2023-12-07.
    #
    # Currently requires access to our private S3 bucket.
    # """
    koopa_has_private_access || return 1
    koopa_can_push_binary && return 1
    return 0
}
