#!/usr/bin/env bash

koopa_current_ensembl_version() {
    # """
    # Current Ensembl version.
    # @note Updated 2023-02-10.
    #
    # @examples
    # > koopa_current_ensembl_version
    # # 105
    # """
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        koopa_parse_url 'ftp://ftp.ensembl.org/pub/README' \
        | "${app['sed']}" -n '3p' \
        | "${app['cut']}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
