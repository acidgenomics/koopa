#!/usr/bin/env bash

koopa_macos_force_eject() {
    # """
    # Force eject a volume.
    # @note Updated 2023-04-05.
    #
    # Spotlight sometimes goes crazy attempting to index volumes, including
    # network drives, which is super annoying. This will allow you to unmount
    # anyway.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['diskutil']="$(koopa_macos_locate_diskutil)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['mount']="/Volumes/${dict['name']}"
    koopa_assert_is_dir "${dict['mount']}"
    "${app['sudo']}" "${app['diskutil']}" unmount force "${dict['mount']}"
    return 0
}
