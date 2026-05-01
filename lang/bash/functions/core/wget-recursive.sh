#!/usr/bin/env bash

_koopa_wget_recursive() {
    # """
    # Download files with wget recursively.
    # @note Updated 2023-04-05.
    #
    # Note that we need to escape the wildcards in the password.
    # For direct input, can just use single quotes to escape.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/379181
    #
    # @examples
    # > _koopa_wget_recursive \
    # >     --url='ftp://ftp.example.com/' \
    # >     --user='user' \
    # >     --password='pass'
    # """
    local -A app dict
    local -a wget_args
    _koopa_assert_has_args "$#"
    app['wget']="$(_koopa_locate_wget)"
    _koopa_assert_is_executable "${app[@]}"
    dict['datetime']="$(_koopa_datetime)"
    dict['password']=''
    dict['url']=''
    dict['user']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--password='*)
                dict['password']="${1#*=}"
                shift 1
                ;;
            '--password')
                dict['password']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--password' "${dict['password']}" \
        '--url' "${dict['url']}" \
        '--user' "${dict['user']}"
    dict['log_file']="wget-${dict['datetime']}.log"
    dict['password']="${dict['password']@Q}"
    wget_args=(
        "--output-file=${dict['log_file']}"
        "--password=${dict['password']}"
        "--user=${dict['user']}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
        "${dict['url']}"/*
    )
    "${app['wget']}" "${wget_args[@]}"
    return 0
}
