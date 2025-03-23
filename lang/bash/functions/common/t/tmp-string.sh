#!/usr/bin/env bash

koopa_tmp_string() {
    # """
    # Temporary directory and file string generator.
    # @note Updated 2023-10-20.
    # """
    koopa_print ".koopa-tmp-$(koopa_random_string)"
    return 0
}
