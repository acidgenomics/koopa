#!/usr/bin/env bash

# FIXME This uses 4.2-arm64 on Apple Silicon...why???

koopa_macos_r_prefix() {
    # """
    # macOS R installation prefix.
    # @note Updated 2023-03-19.
    # """
    koopa_print '/Library/Frameworks/R.framework/Versions/Current/Resources'
    return 0
}
