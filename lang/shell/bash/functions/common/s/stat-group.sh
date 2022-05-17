#!/usr/bin/env bash

koopa_stat_group() {
    # """
    # Get the current group of a file or directory.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_group '/tmp'
    # # wheel
    # """
    koopa_stat '%G' "$@"
}
