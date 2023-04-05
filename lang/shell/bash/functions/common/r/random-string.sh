#!/usr/bin/env bash

koopa_random_string() {
    # """
    # Generate a random string of a desired length.
    # @note Updated 2023-02-15.
    #
    # Alternative approach:
    # openssl rand -hex 10
    #
    # @seealso
    # - https://linuxhint.com/generate-random-string-bash/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['head']="$(koopa_locate_head --allow-system)"
        ['md5sum']="$(koopa_locate_md5sum --allow-system)"
    )
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['md5sum']}" ]] || exit 1
    declare -A dict=(
        ['length']=10
        ['seed']="${RANDOM:?}"
    )
    dict['str']="$( \
        koopa_print "${dict['seed']}" \
        | "${app['md5sum']}" \
        | "${app['head']}" -c "${dict['length']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
