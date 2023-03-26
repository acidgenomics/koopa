#!/usr/bin/env bash

koopa_stat_access_octal() {
    # """
    # Get the current access permissions in octal form.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/get-octal-file-permissions-from-
    #     command-line-on-linuxunix/
    #
    # @examples
    # > koopa_stat_access_octal '/tmp'
    # # 755
    # """
    # FIXME BSD use '%OLp' or '%A'.
    koopa_stat '%a' "$@"
}
