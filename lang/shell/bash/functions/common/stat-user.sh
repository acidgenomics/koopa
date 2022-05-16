#!/usr/bin/env bash

koopa_stat_user() {
    # """
    # Get the current user (owner) of a file or directory.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_user '/tmp'
    # # root
    # """
    koopa_stat '%U' "$@"
}
