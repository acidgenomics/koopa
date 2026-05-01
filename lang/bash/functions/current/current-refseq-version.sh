#!/usr/bin/env bash

_koopa_current_refseq_version() {
    # """
    # Current RefSeq version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > _koopa_current_refseq_version
    # # 210
    # """
    local str url
    _koopa_assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    str="$(_koopa_parse_url "$url")"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
