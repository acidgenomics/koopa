#!/bin/sh

_koopa_export_home() {
    # """
    # Ensure that 'HOME' variable is exported.
    # @note Updated 2023-05-12
    # """
    [ -z "${HOME:-}" ] && HOME="$(pwd)"
    export HOME
    return 0
}
