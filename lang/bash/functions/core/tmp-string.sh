#!/usr/bin/env bash

_koopa_tmp_string() {
    # """
    # Temporary directory and file string generator.
    # @note Updated 2023-10-20.
    # """
    _koopa_print ".koopa-tmp-$(_koopa_random_string)"
    return 0
}
