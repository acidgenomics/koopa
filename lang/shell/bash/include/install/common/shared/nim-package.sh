#!/usr/bin/env bash

main() {
    # """
    # Install Nim package using nimble.
    # @note Updated 2022-07-08.
    #
    # @seealso
    # - https://github.com/nim-lang/nimble/issues/734
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    local -A app=(
        ['nim']="$(koopa_locate_nim)"
        ['nimble']="$(koopa_locate_nimble)"
    )
    [[ -x "${app['nim']}" ]] || exit 1
    [[ -x "${app['nimble']}" ]] || exit 1
    local -A dict=(
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    export NIMBLE_DIR="${dict['prefix']}"
    "${app['nimble']}" \
        --accept \
        --nim:"${app['nim']}" \
        install "${dict['name']}@${dict['version']}"
    return 0
}
