#!/usr/bin/env bash

_koopa_current_bioconductor_version() {
    # """
    # Current Bioconductor version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > _koopa_current_bioconductor_version
    # # 3.14
    # """
    local str
    _koopa_assert_has_no_args "$#"
    str="$(_koopa_parse_url 'https://bioconductor.org/bioc-version')"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
