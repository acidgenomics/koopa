#!/usr/bin/env bash

koopa_install_python311() {
    local dict
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['man1_prefix']="$(koopa_man1_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    koopa_install_app \
        --installer='python' \
        --name='python3.11' \
        "$@"
    (
        koopa_alert "Linking 'python' in '${dict['app_prefix']}'."
        koopa_cd "${dict['app_prefix']}"
        koopa_ln 'python3.11' 'python'
        koopa_alert "Linking 'python' in '${dict['bin_prefix']}'."
        koopa_cd "${dict['bin_prefix']}"
        koopa_ln 'python3.11' 'python3'
        koopa_ln 'python3.11' 'python'
        koopa_alert "Linking 'python' in '${dict['man1_prefix']}'."
        koopa_cd "${dict['man1_prefix']}"
        koopa_ln 'python3.11.1' 'python3.1'
        koopa_ln 'python3.11.1' 'python.1'
        koopa_alert "Linking 'python' in '${dict['opt_prefix']}'."
        koopa_cd "${dict['opt_prefix']}"
        koopa_ln 'python3.11' 'python'
    )
    return 0
}
