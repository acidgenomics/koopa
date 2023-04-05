#!/usr/bin/env bash

koopa_macos_install_system_rosetta() {
    local app
    local -A app=(
        ['softwareupdate']="$(koopa_macos_locate_softwareupdate)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['softwareupdate']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['softwareupdate']}" --install-rosetta
    return 0
}
