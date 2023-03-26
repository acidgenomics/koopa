#!/usr/bin/env bash

koopa_stat_access_human() {
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/get-octal-file-permissions-from-
    #     command-line-on-linuxunix/
    #
    # @examples
    # > koopa_stat_access_human '/tmp'
    # # lrwxr-xr-x
    # """
    # FIXME BSD use: '%Sp'.
    koopa_stat '%A' "$@"
}
