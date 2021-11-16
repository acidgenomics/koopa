#!/usr/bin/env bash

koopa::macos_create_dmg() { # {{{1
    # """
    # Create DMG image.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [hdiutil]="$(koopa::locate_hdiutil)"
    )
    declare -A dict=(
        [srcfolder]="${1:?}"
    )
    koopa::assert_is_dir "${dict[srcfolder]}"
    dict[srcfolder]="$(koopa::realpath "${dict[srcfolder]}")"
    dict[volname]="$(koopa::basename "${dict[volname]}")"
    dict[ov]="${dict[volname]}.dmg"
    "${app[hdiutil]}" create \
        -ov "${dict[ov]}" \
        -srcfolder "${dict[srcfolder]}" \
        -volname "${dict[volname]}"
    return 0
}
