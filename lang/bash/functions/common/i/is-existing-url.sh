#!/usr/bin/env bash

koopa_is_existing_url() {
    # """
    # Check if input is a URL and exists (is active).
    # @note Updated 2023-11-03.
    #
    # @section cURL approach:
    #
    # Can also use "--range '0-0'" instead of '--head' here.
    #
    # @section wget approach:
    #
    # > "${app['wget']}" --spider "$url" 2>/dev/null || return 1
    #
    # @seealso
    # - https://stackoverflow.com/questions/12199059/
    #
    # @examples
    # # TRUE:
    # > koopa_is_existing_url 'https://google.com/'
    #
    # # FALSE:
    # > koopa_is_existing_url 'https://google.com/asdf'
    # """
    local -A app
    local url
    koopa_assert_has_args "$#"
    koopa_is_url "$@" || return 1
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for url in "$@"
    do
        "${app['curl']}" \
            --disable \
            --fail \
            --head \
            --location \
            --output /dev/null \
            --silent \
            "$url" \
            || return 1
        continue
    done
    return 0
}
