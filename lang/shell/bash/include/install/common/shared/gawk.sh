#!/usr/bin/env bash

main() {
    # Install gawk.
    # @note Updated 2022-09-12.
    # """
    local dict
    declare -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    )
    koopa_activate_app \
        'gettext' \
        'mpfr' \
        'readline'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='gawk' \
        "$@"
    (
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln 'gawk.1' 'awk.1'
    )
    return 0
}
