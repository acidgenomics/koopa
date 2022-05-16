#!/usr/bin/env bash

koopa_current_bcbio_nextgen_version() {
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2022-02-25.
    #
    # This approach checks for latest stable release available via bioconda.
    #
    # @examples
    # > koopa_current_bcbio_nextgen_version
    # # 1.2.9
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    str="$( \
        koopa_parse_url "https://raw.githubusercontent.com/bcbio/\
bcbio-nextgen/master/requirements-conda.txt" \
            | koopa_grep --pattern='bcbio-nextgen=' \
            | "${app[cut]}" -d '=' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
