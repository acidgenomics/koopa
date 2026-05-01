#!/usr/bin/env bash

_koopa_convert_line_endings_from_lf_to_crlf() {
    # """
    # Convert LF (Unix) to CRLF (Windows) line endings.
    # @note Updated 2022-02-13.
    #
    # @seealso
    # - https://stackoverflow.com/questions/27810758/
    #
    # @examples
    # > _koopa_convert_line_endings_from_lf_to_crlf 'metadata.csv'
    # """
    local -A app
    local file
    _koopa_assert_has_ars "$#"
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
        _koopa_mv "${file}.tmp" "$file"
    done
    return 0
}
