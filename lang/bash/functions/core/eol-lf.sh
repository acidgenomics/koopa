#!/usr/bin/env bash

_koopa_eol_lf() {
    # """
    # Ensure line breaks are Unix LF.
    # @note Updated 2022-11-17.
    #
    # @seealso
    # - https://gist.github.com/jennybc/0be7717c2b5b30088811
    # - https://github.com/dfalster/baad/blob/master/scripts/fix-eol.sh
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['perl']="$(_koopa_locate_perl)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        _koopa_alert "Setting EOL as LF in '${file}'."
        # Convert Windows to Unix.
        "${app['perl']}" -pi -e 's/\r\n/\n/g' "$file"
        # Convert old Mac to Unix (Excel).
        "${app['perl']}" -pi -e 's/\r/\n/g' "$file"
    done
}
