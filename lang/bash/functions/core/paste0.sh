#!/usr/bin/env bash

_koopa_paste0() {
    # """
    # Paste arguments to string without a delimiter.
    # @note Updated 2021-11-30.
    #
    # @examples
    # > _koopa_paste0 'aaa' 'bbb'
    # # aaabbb
    # """
    _koopa_paste --sep='' "$@"
}
