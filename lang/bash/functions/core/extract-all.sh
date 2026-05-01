#!/usr/bin/env bash

_koopa_extract_all() {
    # """
    # Extract multiple compressed archives in a single call.
    # @note Updated 2022-03-28.
    #
    # @usage _koopa_extract_all FILE...
    #
    # @examples
    # > _koopa_extract_all 'file1.tar.bz2' 'file2.tar.gz' 'file3.tar.xz'
    # """
    local file
    _koopa_assert_has_args_ge "$#" 2
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        _koopa_assert_is_matching_regex \
            --pattern='\.tar\.(bz2|gz|xz)$' \
            --string="$file"
        _koopa_extract "$file"
    done
    return 0
}
