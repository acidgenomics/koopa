#!/usr/bin/env bash

koopa_random_string() {
    # """
    # Generate a random string of a desired length.
    # @note Updated 2023-05-24.
    #
    # Alternative approach:
    # openssl rand -hex 10
    #
    # @seealso
    # - https://linuxhint.com/generate-random-string-bash/
    #
    # @examples
    # koopa_random_string --length=5 --seed=42
    # """
    local -A app dict
    app['head']="$(koopa_locate_head --allow-system)"
    app['md5sum']="$(koopa_locate_md5sum --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['length']=10
    dict['seed']="${RANDOM:?}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--length='*)
                dict['length']="${1#*=}"
                shift 1
                ;;
            '--length')
                dict['length']="${2:?}"
                shift 2
                ;;
            '--seed='*)
                dict['seed']="${1#*=}"
                shift 1
                ;;
            '--seed')
                dict['seed']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${dict['length']}" -le 32 ]] || return 1
    dict['str']="$( \
        koopa_print "${dict['seed']}" \
        | "${app['md5sum']}" \
        | "${app['head']}" -c "${dict['length']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
