#!/usr/bin/env bash

koopa::macos_download_macos() { # {{{1
    # """
    # Download a full copy of macOS system installer.
    # @note Updated 2020-11-20.
    #
    # @seealso
    # - https://scriptingosx.com/2019/10/
    #       download-a-full-install-macos-app-with-softwareupdate-in-catalina/
    # """
    local version
    version="${1:?}"
    koopa::assert_is_macos
    softwareupdate \
        --fetch-full-installer \
        --full-installer-version "$version"
    return 0
}
