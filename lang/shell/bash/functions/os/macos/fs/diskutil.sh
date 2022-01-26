#!/usr/bin/env bash

koopa::macos_force_eject() { # {{{1
    # """
    # Force eject a volume.
    # @note Updated 2021-11-16.
    #
    # Spotlight sometimes goes crazy attempting to index volumes, including
    # network drives, which is super annoying. This will allow you to unmount
    # anyway.
    # """
    local app mount name
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [diskutil]="$(koopa::macos_locate_diskutil)"
        [sudo]="$(koopa::locate_sudo)"
    )
    name="${1:?}"
    mount="/Volumes/${name}"
    koopa::assert_is_dir "$mount"
    "${app[sudo]}" "${app[diskutil]}" unmount force "$mount"
    return 0
}
