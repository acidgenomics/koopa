#!/usr/bin/env bash

koopa_extract_all() {
    # """
    # Extract multiple compressed archives in a single call.
    # @note Updated 2022-03-28.
    #
    # @usage koopa_extract_all FILE...
    #
    # @examples
    # > koopa_extract_all 'file1.tar.bz2' 'file2.tar.gz' 'file3.tar.xz'
    # """
    local file
    koopa_assert_has_args_ge "$#" 2
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        koopa_assert_is_matching_regex \
            --pattern='\.tar\.(bz2|gz|xz)$' \
            --string="$file"
        koopa_extract "$file"
    done
    return 0
}
