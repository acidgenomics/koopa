#!/usr/bin/env bash

koopa_ftp_mirror() {
    # """
    # Mirror contents from an FTP server.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['wget']="$(koopa_locate_wget)"
    koopa_assert_is_executable "${app[@]}"
    dict['dir']=''
    dict['host']=''
    dict['user']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--dir='*)
                dict['dir']="${1#*=}"
                shift 1
                ;;
            '--dir')
                dict['dir']="${2:?}"
                shift 2
                ;;
            '--host='*)
                dict['host']="${1#*=}"
                shift 1
                ;;
            '--host')
                dict['host']="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict['user']="${1#*=}"
                shift 1
                ;;
            '--user')
                dict['user']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--host' "${dict['host']}" \
        '--user' "${dict['user']}"
    if [[ -n "${dict['dir']}" ]]
    then
        dict['dir']="${dict['host']}/${dict['dir']}"
    else
        dict['dir']="${dict['host']}"
    fi
    "${app['wget']}" \
        --ask-password \
        --mirror \
        "ftp://${dict['user']}@${dict['dir']}/"*
    return 0
}
