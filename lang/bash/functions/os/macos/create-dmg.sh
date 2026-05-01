#!/usr/bin/env bash

_koopa_macos_create_dmg() {
    # """
    # Create DMG image.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['hdiutil']="$(_koopa_macos_locate_hdiutil)"
    _koopa_assert_is_executable "${app[@]}"
    dict['srcfolder']="${1:?}"
    _koopa_assert_is_dir "${dict['srcfolder']}"
    dict['srcfolder']="$(_koopa_realpath "${dict['srcfolder']}")"
    dict['volname']="$(_koopa_basename "${dict['volname']}")"
    dict['ov']="${dict['volname']}.dmg"
    "${app['hdiutil']}" create \
        -ov "${dict['ov']}" \
        -srcfolder "${dict['srcfolder']}" \
        -volname "${dict['volname']}"
    return 0
}
