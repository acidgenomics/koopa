#!/usr/bin/env bash

koopa_macos_force_eject() {
    # """
    # Force eject a volume.
    # @note Updated 2022-07-26.
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
    declare -A dict
    dict[name]="${1:?}"
    dict[mount]="/Volumes/${dict[name]}"
    koopa_assert_is_dir "${dict[mount]}"
    "${app[sudo]}" "${app[diskutil]}" unmount force "${dict[mount]}"
    return 0
}
