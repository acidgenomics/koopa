#!/usr/bin/env bash

koopa_convert_line_endings_from_crlf_to_lf() { # {{{1
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
    # > koopa_convert_line_endings_from_crlf_to_lf 'metadata.csv'
    # """
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    for file in "$@"
    do
        "${app[perl]}" -pe 's/\r$//g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

koopa_convert_line_endings_from_lf_to_crlf() { # {{{1
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
    local app file
    koopa_assert_has_ars "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    for file in "$@"
    do
        "${app[perl]}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}
