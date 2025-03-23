#!/usr/bin/env bash

koopa_is_compressed_file() {
    # """
    # Does the input contain a compressed file?
    # @note Updated 2023-10-23.
    #
    # File must exist on disk.
    #
    # @examples
    # koopa_is_compressed_file 'example.gz'
    # """
    local pattern string
    koopa_assert_has_args "$#"
    pattern="$(koopa_compress_ext_pattern)"
    for string in "$@"
    do
        [[ -f "$string" ]] || return 1
        koopa_str_detect_regex \
            --pattern="$pattern" \
            --string="$string" \
        || return 1
    done
    return 0
}
