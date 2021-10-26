#!/usr/bin/env bash

koopa::macos_create_dmg() { # {{{1
    # """
    # Create DMG image.
    # @note Updated 2021-10-26.
    # """
    local dir name
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed 'hdiutil'
    dir="${1:?}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    name="$(koopa::basename "$dir")"
    hdiutil create \
        -volname "$name" \
        -srcfolder "$dir" \
        -ov "${name}.dmg"
    return 0
}
