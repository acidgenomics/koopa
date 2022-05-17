#!/usr/bin/env bash

koopa_stat_access_octal() {
    # """
    # Get the current access permissions in octal form.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_access_octal '/tmp'
    # # 755
    # """
    koopa_stat '%a' "$@"
}
