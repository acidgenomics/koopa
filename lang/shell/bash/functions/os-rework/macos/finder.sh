#!/usr/bin/env bash

koopa_macos_finder_hide() {
    # """
    # Hide files from view in the Finder.
    # @note Updated 2021-05-08.
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'setfile'
    setfile -a V "$@"
    return 0
}

koopa_macos_finder_unhide() {
    # """
    # Unhide files from view in the Finder.
    # @note Updated 2021-05-08.
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'setfile'
    setfile -a v "$@"
    return 0
}
