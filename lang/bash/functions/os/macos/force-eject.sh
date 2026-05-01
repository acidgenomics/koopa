#!/usr/bin/env bash

_koopa_macos_force_eject() {
    # """
    # Force eject a volume.
    # @note Updated 2023-05-01.
    #
    # Spotlight sometimes goes crazy attempting to index volumes, including
    # network drives, which is super annoying. This will allow you to unmount
    # anyway.
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    _koopa_assert_is_admin
    app['diskutil']="$(_koopa_macos_locate_diskutil)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['mount']="/Volumes/${dict['name']}"
    _koopa_assert_is_dir "${dict['mount']}"
    _koopa_sudo "${app['diskutil']}" unmount force "${dict['mount']}"
    return 0
}
