#!/usr/bin/env bash

koopa_tmp_dir_in_wd() {
    # """
    # Create temporary directory in current working directory.
    # @note Updated 2023-10-20.
    # """
    koopa_init_dir "tmp-koopa-$(koopa_random_string)"
    return 0
}
