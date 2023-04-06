#!/usr/bin/env bash

koopa_macos_install_system_rosetta() {
    # """
    # Install Rosetta 2.
    # @note Updated 2023-04-05.
    # """
    local -A app
    app['softwareupdate']="$(koopa_macos_locate_softwareupdate)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['softwareupdate']}" --install-rosetta
    return 0
}
