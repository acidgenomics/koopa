#!/bin/sh

_koopa_is_root() {
    # """
    # Is the current user root?
    # @note Updated 2020-04-16.
    # """
    [ "$(_koopa_user_id)" -eq 0 ]
}
