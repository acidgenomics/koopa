#!/usr/bin/env bash

koopa_tmp_file_in_wd() {
    # """
    # Create temporary file in current working directory.
    # @note Updated 2023-10-20.
    # """
    local file
    file="$(koopa_tmp_string)"
    koopa_touch "$file"
    koopa_assert_is_file "$file"
    koopa_realpath "$file"
    return 0
}
