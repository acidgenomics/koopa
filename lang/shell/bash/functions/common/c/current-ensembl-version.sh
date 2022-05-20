#!/usr/bin/env bash

koopa_current_ensembl_version() {
    # """
    # Current Ensembl version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_ensembl_version
    # # 105
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    str="$( \
        koopa_parse_url 'ftp://ftp.ensembl.org/pub/current_README' \
        | "${app[sed]}" -n '3p' \
        | "${app[cut]}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
