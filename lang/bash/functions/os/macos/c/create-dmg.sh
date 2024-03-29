#!/usr/bin/env bash

koopa_macos_create_dmg() {
    # """
    # Create DMG image.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['hdiutil']="$(koopa_macos_locate_hdiutil)"
    koopa_assert_is_executable "${app[@]}"
    dict['srcfolder']="${1:?}"
    koopa_assert_is_dir "${dict['srcfolder']}"
    dict['srcfolder']="$(koopa_realpath "${dict['srcfolder']}")"
    dict['volname']="$(koopa_basename "${dict['volname']}")"
    dict['ov']="${dict['volname']}.dmg"
    "${app['hdiutil']}" create \
        -ov "${dict['ov']}" \
        -srcfolder "${dict['srcfolder']}" \
        -volname "${dict['volname']}"
    return 0
}
