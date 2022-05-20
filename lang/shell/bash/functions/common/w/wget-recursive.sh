#!/usr/bin/env bash

koopa_wget_recursive() {
    # """
    # Download files with wget recursively.
    # @note Updated 2022-02-10.
    #
    # Note that we need to escape the wildcards in the password.
    # For direct input, can just use single quotes to escape.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/379181
    #
    # @examples
    # > koopa_wget_recursive \
    # >     --url='ftp://ftp.example.com/' \
    # >     --user='user' \
    # >     --password='pass'
    # """
    local app dict wget_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [wget]="$(koopa_locate_wget)"
    )
    declare -A dict=(
        [datetime]="$(koopa_datetime)"
        [password]=''
        [url]=''
        [user]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--password='*)
                dict[password]="${1#*=}"
                shift 1
                ;;
            '--password')
                dict[password]="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict[url]="${1#*=}"
                shift 1
                ;;
            '--url')
                dict[url]="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict[user]="${1#*=}"
                shift 1
                ;;
            '--user')
                dict[user]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--password' "${dict[password]}" \
        '--url' "${dict[url]}" \
        '--user' "${dict[user]}"
    dict[log_file]="wget-${dict[datetime]}.log"
    dict[password]="${dict[password]@Q}"
    wget_args=(
        "--output-file=${dict[log_file]}"
        "--password=${dict[password]}"
        "--user=${dict[user]}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
        "${dict[url]}"/*
    )
    "${app[wget]}" "${wget_args[@]}"
    return 0
}
