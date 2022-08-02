#!/usr/bin/env bash

koopa_shared_ext() {
    # """
    # Shared object extension.
    # @note Updated 2022-08-02.
    # """
    local str
    if koopa_is_macos
    then
        str='dylib'
    else
        str='so'
    fi
    koopa_print "$str"
    return 0
}
