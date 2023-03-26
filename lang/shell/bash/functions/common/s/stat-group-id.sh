#!/usr/bin/env bash

koopa_stat_group_id() {
    # """
    # Get the current group name of a file or directory.
    # @note Updated 2023-03-26.
    #
    # @examples
    # > koopa_stat_group_id '/tmp'
    # # 0
    # """
    koopa_stat '%g' "$@"
}
