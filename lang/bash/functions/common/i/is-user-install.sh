#!/usr/bin/env bash

koopa_is_user_install() {
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2023-03-11.
    # """
    koopa_str_detect_fixed \
       --pattern="${HOME:?}" \
       --string="$(koopa_koopa_prefix)"
}
