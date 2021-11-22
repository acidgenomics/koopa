#!/usr/bin/env bash

koopa::macos_finder_hide() { # {{{1
    # """
    # Hide files from view in the Finder.
    # @note Updated 2021-05-08.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'setfile'
    setfile -a V "$@"
    return 0
}

koopa::macos_finder_unhide() { # {{{1
    # """
    # Unhide files from view in the Finder.
    # @note Updated 2021-05-08.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'setfile'
    setfile -a v "$@"
    return 0
}
