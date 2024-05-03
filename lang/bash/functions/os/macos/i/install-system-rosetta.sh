#!/usr/bin/env bash

koopa_macos_install_system_rosetta() {
    # """
    # Install Rosetta 2.
    # @note Updated 2024-05-03.
    #
    # @seealso
    # - https://github.com/rstudio/rstudio/issues/12791
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['softwareupdate']="$(koopa_macos_locate_softwareupdate)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['softwareupdate']}" \
        --install-rosetta \
        --agree-to-license
    return 0
}
