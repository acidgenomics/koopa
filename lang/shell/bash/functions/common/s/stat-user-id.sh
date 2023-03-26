#!/usr/bin/env bash

koopa_stat_user_id() {
    # """
    # Get the current user (owner) identifier of a file or directory.
    # @note Updated 2023-03-26.
    #
    # @examples
    # > koopa_stat_user_id '/tmp'
    # # 0
    # """
    koopa_stat '%u' "$@"
}
