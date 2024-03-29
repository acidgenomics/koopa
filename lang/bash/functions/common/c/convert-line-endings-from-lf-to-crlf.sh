#!/usr/bin/env bash

koopa_convert_line_endings_from_lf_to_crlf() {
    # """
    # Convert LF (Unix) to CRLF (Windows) line endings.
    # @note Updated 2022-02-13.
    #
    # @seealso
    # - https://stackoverflow.com/questions/27810758/
    #
    # @examples
    # > koopa_convert_line_endings_from_lf_to_crlf 'metadata.csv'
    # """
    local -A app
    local file
    koopa_assert_has_ars "$#"
    app['perl']="$(koopa_locate_perl)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}
