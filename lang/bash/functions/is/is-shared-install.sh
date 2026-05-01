#!/usr/bin/env bash

_koopa_is_shared_install() {
    # """
    # Is koopa installed for all users (shared)?
    # @note Updated 2023-01-10.
    # """
    ! _koopa_is_user_install
}
