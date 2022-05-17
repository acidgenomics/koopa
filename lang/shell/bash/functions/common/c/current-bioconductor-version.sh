#!/usr/bin/env bash

koopa_current_bioconductor_version() {
    # """
    # Current Bioconductor version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_bioconductor_version
    # # 3.14
    # """
    local str
    koopa_assert_has_no_args "$#"
    str="$(koopa_parse_url 'https://bioconductor.org/bioc-version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
