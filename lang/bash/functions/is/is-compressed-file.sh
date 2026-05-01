#!/usr/bin/env bash

_koopa_is_compressed_file() {
    # """
    # Does the input contain a compressed file?
    # @note Updated 2023-10-23.
    #
    # File must exist on disk.
    #
    # @examples
    # _koopa_is_compressed_file 'example.gz'
    # """
    local pattern string
    _koopa_assert_has_args "$#"
    pattern="$(_koopa_compress_ext_pattern)"
    for string in "$@"
    do
        [[ -f "$string" ]] || return 1
        _koopa_str_detect_regex \
            --pattern="$pattern" \
            --string="$string" \
        || return 1
    done
    return 0
}
