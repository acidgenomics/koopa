#!/usr/bin/env bash

koopa_download_cran_latest() {
    # """
    # Download CRAN latest.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local name
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local file pattern url
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[-.0-9]+.tar.gz"
        file="$( \
            koopa_parse_url "$url" \
            | koopa_grep \
                --only-matching \
                --pattern="$pattern" \
                --regex \
            | "${app['head']}" -n 1 \
        )"
        koopa_download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}
