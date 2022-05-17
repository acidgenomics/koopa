#!/usr/bin/env bash

koopa_hdf5_version() {
    # """
    # HDF5 version.
    # @note Updated 2022-02-27.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [h5cc]="$(koopa_locate_h5cc)"
        [sed]="$(koopa_locate_sed)"
    )
    str="$( \
        "${app[h5cc]}" -showconfig \
            | koopa_grep --pattern='HDF5 Version:' \
            | "${app[sed]}" -E 's/^(.+): //' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
