#!/usr/bin/env bash

koopa_stat_access_human() {
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_access_human '/tmp'
    # # lrwxr-xr-x
    # """
    koopa_stat '%A' "$@"
}
