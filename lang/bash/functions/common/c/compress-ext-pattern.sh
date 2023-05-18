#!/usr/bin/env bash

koopa_compress_ext_pattern() {
    # """
    # Compressed file extension pattern.
    # @note Updated 2022-01-11.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '\.(bz2|gz|xz|zip)$'
    return 0
}
