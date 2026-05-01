#!/usr/bin/env bash

_koopa_tmp_dir_in_wd() {
    # """
    # Create temporary directory in current working directory.
    # @note Updated 2023-10-20.
    # """
    _koopa_init_dir "$(_koopa_tmp_string)"
    return 0
}
