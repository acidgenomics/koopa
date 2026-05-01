#!/usr/bin/env bash

_koopa_macos_install_system_rosetta() {
    # """
    # Install Rosetta 2.
    # @note Updated 2024-05-03.
    #
    # @seealso
    # - https://github.com/rstudio/rstudio/issues/12791
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['softwareupdate']="$(_koopa_macos_locate_softwareupdate)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['softwareupdate']}" \
        --install-rosetta \
        --agree-to-license
    return 0
}
