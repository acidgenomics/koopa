#!/usr/bin/env bash

koopa_paste0() {
    # """
    # Paste arguments to string without a delimiter.
    # @note Updated 2021-11-30.
    #
    # @examples
    # > koopa_paste0 'aaa' 'bbb'
    # # aaabbb
    # """
    koopa_paste --sep='' "$@"
}
