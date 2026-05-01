#!/usr/bin/env bash

_koopa_shared_ext() {
    # """
    # Shared object extension.
    # @note Updated 2022-08-02.
    # """
    local str
    if _koopa_is_macos
    then
        str='dylib'
    else
        str='so'
    fi
    _koopa_print "$str"
    return 0
}
