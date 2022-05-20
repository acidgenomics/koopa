#!/usr/bin/env bash

koopa_paste() {
    # """
    # Paste arguments into a string separated by delimiter.
    # @note Updated 2022-02-24.
    #
    # NB Don't harden against '-*' input here, as we want to be able to pass in
    # arguments that begin with '-'. This is useful in some edge cases, such as
    # curly bracket glob handling in GNU find engine of 'koopa_find' function.
    #
    # @seealso
    # - https://stackoverflow.com/a/57536163/3911732/
    # - https://stackoverflow.com/questions/13470413/
    # - https://stackoverflow.com/questions/1527049/
    #
    # @examples
    # > koopa_paste --sep=', ' 'aaa bbb' 'ccc ddd'
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
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    IFS=''
    str="${*/#/$sep}"
    str="${str:${#sep}}"
    koopa_print "$str"
    return 0
}
