#!/usr/bin/env bash

koopa_is_shared_install() {
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2023-01-10.
    # """
    ! koopa_is_user_install
}
