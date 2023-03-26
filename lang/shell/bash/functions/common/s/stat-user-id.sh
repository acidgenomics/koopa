#!/usr/bin/env bash

koopa_stat_user_id() {
    # """
    # Get the current user (owner) identifier of a file or directory.
    # @note Updated 2022-11-28.
    #
    # Usage of '%U' isn't compatible with BSD.
    #
    # @examples
    # > koopa_stat_user '/tmp'
    # # 501
    # """
    koopa_stat '%u' "$@"
}
