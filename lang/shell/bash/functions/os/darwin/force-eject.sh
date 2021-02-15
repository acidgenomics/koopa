#!/usr/bin/env bash

koopa::macos_force_eject() { # {{{1
    # """
    # Force eject a volume.
    # @note Updated 2020-01-06.
    #
    # Spotlight sometimes goes crazy attempting to index volumes, including
    # network drives, which is super annoying. This will allow you to unmount
    # anyway.
    # """
    local mount name
    koopa::assert_has_args_eq "$#" 1
    name="${1:?}"
    mount="/Volumes/${name}"
    sudo diskutil unmount force "$mount"
    return 0
}
