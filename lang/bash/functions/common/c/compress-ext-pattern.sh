#!/usr/bin/env bash

koopa_compress_ext_pattern() {
    # """
    # Compressed file extension pattern.
    # @note Updated 2023-05-31.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/List_of_archive_formats
    # """
    local -a formats
    local str
    koopa_assert_has_no_args "$#"
    formats=('7z' 'br' 'bz2' 'gz' 'lz' 'lz4' 'lzma' 'xz' 'z' 'zip' 'zst')
    str="$(koopa_paste --sep='|' "${formats[@]}")"
    str="\.(${str})\$"
    koopa_print "$str"
    return 0
}
