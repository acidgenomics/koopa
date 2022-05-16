#!/usr/bin/env bash

koopa_download_cran_latest() {
    # """
    # Download CRAN latest.
    # @note Updated 2021-10-25.
    # """
    local app file name pattern url
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    for name in "$@"
    do
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[-.0-9]+.tar.gz"
        file="$( \
            koopa_parse_url "$url" \
            | koopa_grep \
                --only-matching \
                --pattern="$pattern" \
                --regex \
            | "${app[head]}" -n 1 \
        )"
        koopa_download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}
