#!/usr/bin/env bash

koopa_stat_group_name() {
    # """
    # Get the current group name of a file or directory.
    # @note Updated 2023-03-26.
    #
    # @examples
    # > koopa_stat_group '/tmp'
    # # wheel
    # """
    koopa_stat '%G' "$@"
}
