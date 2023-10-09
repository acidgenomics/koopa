#!/usr/bin/env bash

koopa_macos_xcode_clt_major_version() {
    # """
    # Xcode CLT major version.
    # @note Updated 2023-10-09.
    # """
    local str
    str="$(koopa_macos_xcode_clt_version)"
    str="$(koopa_major_version "$str")"
    koopa_print "$str"
    return 0
}
