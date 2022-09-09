#!/usr/bin/env bash

main() {
    local dict
    declare -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    )
    koopa_activate_opt_prefix 'm4'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='libtool' \
        -D '--program-prefix=g' \
        "$@"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln 'glibtool' 'libtool'
        koopa_ln 'glibtoolize' 'libtoolize'
    )
    return 0
}
