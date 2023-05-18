#!/usr/bin/env bash

koopa_random_string() {
    # """
    # Generate a random string of a desired length.
    # @note Updated 2023-04-05.
    #
    # Alternative approach:
    # openssl rand -hex 10
    #
    # @seealso
    # - https://linuxhint.com/generate-random-string-bash/
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    app['md5sum']="$(koopa_locate_md5sum --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['length']=10
    dict['seed']="${RANDOM:?}"
    dict['str']="$( \
        koopa_print "${dict['seed']}" \
        | "${app['md5sum']}" \
        | "${app['head']}" -c "${dict['length']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
