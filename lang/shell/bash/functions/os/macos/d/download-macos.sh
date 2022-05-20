#!/usr/bin/env bash

koopa_macos_download_macos() {
    # """
    # Download a full copy of macOS system installer.
    # @note Updated 2022-05-20.
    #
    # Note that you can only download a Catalina installer on Catalina.
    # Attempting to do this on a machine running Big Sur will fail.
    #
    # @seealso
    # - https://scriptingosx.com/2019/10/
    #       download-a-full-install-macos-app-with-softwareupdate-in-catalina/
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [softwareupdate]="$(koopa_macos_locate_softwareupdate)"
    )
    declare -A dict=(
        [version]="${1:?}"
    )
    "${app[softwareupdate]}" \
        --fetch-full-installer \
        --full-installer-version "${dict[version]}"
    return 0
}
