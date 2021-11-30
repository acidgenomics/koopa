#!/usr/bin/env bash

koopa::capitalize() { # {{{1
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2021-11-30.
    #
    # @examples
    # koopa::capitalize 'hello world' 'foo bar'
    # ## 'Hello world' 'Foo bar'
    # @seealso
    # - https://stackoverflow.com/a/12487465
    # """
    local app str
    koopa::assert_has_args "$#"
    declare -A app=(
        [tr]="$(koopa::locate_tr)"
    )
    for str in "$@"
    do
        str="$("${app[tr]}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa::print "$str"
    done
    return 0
}

koopa::paste() { # {{{1
    # """
    # Paste arguments into a string separated by delimiter.
    # @note Updated 2021-11-30.
    #
    # @seealso
    # - https://stackoverflow.com/a/57536163/3911732/
    # - https://stackoverflow.com/questions/13470413/
    # - https://stackoverflow.com/questions/1527049/
    #
    # @examples
    # > koopa::paste --sep=', ' 'aaa bbb' 'ccc ddd'
    # # aaa bbb, ccc ddd
    # """
    local IFS pos sep str
    sep=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--sep='*)
                sep="${1#*=}"
                shift 1
                ;;
            '--sep')
                sep="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    IFS=''
    str="${*/#/$sep}"
    str="${str:${#sep}}"
    koopa::print "$str"
    return 0
}

koopa::paste0() { # {{{1
    # """
    # Paste arguments to string without a delimiter.
    # @note Updated 2021-11-30.
    #
    # @examples
    # > koopa::paste0 'aaa' 'bbb'
    # # aaabbb
    # """
    koopa::paste --sep='' "$@"
}

koopa::to_string() { # {{{1
    # """
    # Paste arguments to a comma separated string.
    # @note Updated 2021-11-30.
    #
    # @examples
    # > koopa::to_string 'aaa' 'bbb'
    # # aaa, bbb
    # """
    koopa::assert_has_args "$#"
    koopa::paste0 --sep=', ' "$@"
    return 0
}
