#!/usr/bin/env bash

koopa_current_refseq_version() {
    # """
    # Current RefSeq version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_refseq_version
    # # 210
    # """
    local str url
    koopa_assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    str="$(koopa_parse_url "$url")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
