#!/usr/bin/env bash

koopa_compress_ext_pattern() {
    # """
    # Compressed file extension pattern.
    # @note Updated 2023-05-31.
    #
    # Intentionally not including mixed archiving and compression formats here,
    # such as 7z and zip.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/List_of_archive_formats
    # """
    local -a formats
    local str
    koopa_assert_has_no_args "$#"
    formats=('br' 'bz2' 'gz' 'lz' 'lz4' 'lzma' 'xz' 'Z' 'zst')
    str="$(koopa_paste --sep='|' "${formats[@]}")"
    str="\.(${str})\$"
    koopa_print "$str"
    return 0
}
