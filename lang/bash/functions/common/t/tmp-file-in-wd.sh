#!/usr/bin/env bash

koopa_tmp_file_in_wd() {
    # """
    # Create temporary file in current working directory.
    # @note Updated 2023-10-23.
    # """
    local -A dict
    dict['ext']=''
    dict['file']="$(koopa_tmp_string)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--ext='*)
                dict['ext']="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict['ext']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "${dict['ext']}" ]]
    then
        dict['file']="${dict['file']}.${dict['ext']}"
    fi
    koopa_touch "${dict['file']}"
    koopa_assert_is_file "${dict['file']}"
    koopa_realpath "${dict['file']}"
    return 0
}
