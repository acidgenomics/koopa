#!/usr/bin/env bash

__koopa_list_path_priority() {
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2021-01-20.
    #
    # Alternate approach using tr:
    # > tr="$(koopa_locate_tr)"
    # > x="$("$tr" ':' '\n' <<< "$str")"
    #
    # Bash parameter expansion approach:
    # > koopa_print "${PATH//:/$'\n'}"
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # - https://stackoverflow.com/questions/26849247
    # - https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
    # - https://www.unix.com/shell-programming-and-scripting/
    #       77199-splitting-string-awk.html
    # """
    local str
    koopa_assert_has_args_le "$#" 1
    str="${1:-$PATH}"
    str="$(koopa_print "${str//:/$'\n'}")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
