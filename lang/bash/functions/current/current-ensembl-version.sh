#!/usr/bin/env bash

_koopa_current_ensembl_version() {
    # """
    # Current Ensembl version.
    # @note Updated 2023-02-10.
    #
    # @examples
    # > _koopa_current_ensembl_version
    # # 105
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_parse_url 'ftp://ftp.ensembl.org/pub/README' \
        | "${app['sed']}" -n '3p' \
        | "${app['cut']}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
