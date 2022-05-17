#!/usr/bin/env bash

koopa_stat_dereference() {
    # """
    # Dereference input files.
    # @note Updated 2021-11-16.
    #
    # Return quoted file with dereference if symbolic link.
    #
    # @examples
    # > koopa_stat_dereference '/tmp'
    # # '/tmp' -> 'private/tmp'
    # """
    koopa_stat '%N' "$@"
}
