#!/usr/bin/env bash

main() {
    # """
    # Install Nim package using nimble.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/nim-lang/nimble/issues/734
    # """
    local -A app dict
    app['nim']="$(koopa_locate_nim)"
    app['nimble']="$(koopa_locate_nimble)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export NIMBLE_DIR="${dict['prefix']}"
    "${app['nimble']}" \
        --accept \
        --nim:"${app['nim']}" \
        install "${dict['name']}@${dict['version']}"
    return 0
}
