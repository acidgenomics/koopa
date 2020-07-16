#!/usr/bin/env bash

koopa::macos_create_dmg() {
    # """
    # Create DMG image.
    # @note Updated 2020-07-15.
    # """
    local dir name
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed hdiutil
    dir="${1:?}"
    koopa::assert_is_dir "$dir"
    dir="$(realpath "$dir")"
    name="$(basename "$dir")"
    hdiutil create -volname "$name" -srcfolder "$dir" -ov "${name}.dmg"
    return 0
}

koopa::macos_clean_launch_services() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::h1 'Cleaning LaunchServices "Open With" menu.'
    "/System/Library/Frameworks/CoreServices.framework/Frameworks/\
LaunchServices.framework/Support/lsregister" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    killall Finder
    koopa::success 'Clean up was successful.'
    return 0
}
