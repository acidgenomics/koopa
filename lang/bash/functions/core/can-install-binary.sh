#!/usr/bin/env bash

_koopa_can_install_binary() {
    # """
    # Can the current user install and/or push a koopa binary?
    # @note Updated 2024-06-14.
    #
    # Currently requires access to our private S3 bucket.
    # """
    case "${KOOPA_CAN_INSTALL_BINARY:-}" in
        '0')
            return 1
            ;;
        '1')
            return 0
            ;;
    esac
    _koopa_can_build_binary && return 1
    _koopa_has_private_access || return 1
    return 0
}
