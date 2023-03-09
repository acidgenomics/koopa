#!/bin/sh

_koopa_group_id() {
    # """
    # Current user's default group ID.
    # @note Updated 2020-06-30.
    # """
    id -g
    return 0
}
