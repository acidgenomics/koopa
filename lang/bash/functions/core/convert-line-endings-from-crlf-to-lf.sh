#!/usr/bin/env bash

_koopa_convert_line_endings_from_crlf_to_lf() {
    # """
    # Convert CRLF (Windows) to LF (Unix) line endings.
    # @note Updated 2022-02-13.
    #
    # Particularly useful for handling metadata file input that may have been
    # generated in Microsoft Excel, which doesn't save CSV files with LF.
    #
    # @seealso
    # - https://stackoverflow.com/questions/27810758/
    #
    # @examples
    # > _koopa_convert_line_endings_from_crlf_to_lf 'metadata.csv'
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/\r$//g' < "$file" > "${file}.tmp"
        _koopa_mv "${file}.tmp" "$file"
    done
    return 0
}
