#!/usr/bin/env bash

koopa_imagemagick_version() {
    # """
    # ImageMagick version.
    # @note Updated 2022-06-15.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [magick_core_config]="$(koopa_locate_magick_core_config)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[magick_core_config]}" ]] || return 1
    str="$( \
        "${app[magick_core_config]}" --version \
            | "${app[cut]}" -d ' ' -f 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
