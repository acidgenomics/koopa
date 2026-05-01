#!/usr/bin/env bash

_koopa_is_user_install() {
    # """
    # Is koopa installed only for the current user?
    # @note Updated 2023-03-11.
    # """
    _koopa_str_detect_fixed \
       --pattern="${HOME:?}" \
       --string="$(_koopa_koopa_prefix)"
}
