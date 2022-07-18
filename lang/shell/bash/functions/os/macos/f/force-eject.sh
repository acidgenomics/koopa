#!/usr/bin/env bash

# FIXME Rework using dict approach.

koopa_macos_force_eject() {
    # """
    # Force eject a volume.
    # @note Updated 2021-11-16.
    #
    # Spotlight sometimes goes crazy attempting to index volumes, including
    # network drives, which is super annoying. This will allow you to unmount
    # anyway.
    # """
    local app mount name
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [diskutil]="$(koopa_macos_locate_diskutil)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[diskutil]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    name="${1:?}"
    mount="/Volumes/${name}"
    koopa_assert_is_dir "$mount"
    "${app[sudo]}" "${app[diskutil]}" unmount force "$mount"
    return 0
}
