#!/usr/bin/env bash

koopa_macos_create_dmg() { # {{{1
    # """
    # Create DMG image.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [hdiutil]="$(koopa_macos_locate_hdiutil)"
    )
    declare -A dict=(
        [srcfolder]="${1:?}"
    )
    koopa_assert_is_dir "${dict[srcfolder]}"
    dict[srcfolder]="$(koopa_realpath "${dict[srcfolder]}")"
    dict[volname]="$(koopa_basename "${dict[volname]}")"
    dict[ov]="${dict[volname]}.dmg"
    "${app[hdiutil]}" create \
        -ov "${dict[ov]}" \
        -srcfolder "${dict[srcfolder]}" \
        -volname "${dict[volname]}"
    return 0
}
