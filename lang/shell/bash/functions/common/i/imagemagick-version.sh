#!/usr/bin/env bash

koopa_imagemagick_version() {
    # """
    # ImageMagick version.
    # @note Updated 2022-02-23.
    #
    # Other approach, that doesn't keep track of patch version:
    # > koopa_get_version_from_pkg_config 'ImageMagick'
    # """
    local app str
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [magick_core_config]="$(koopa_locate_magick_core_config)"
    )
    koopa_assert_has_no_args "$#"
    str="$( \
        "${app[magick_core_config]}" --version \
            | "${app[cut]}" -d ' ' -f 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
