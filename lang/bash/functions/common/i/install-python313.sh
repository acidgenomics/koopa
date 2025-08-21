#!/usr/bin/env bash

koopa_install_python313() {
    local -A dict
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['man1_prefix']="$(koopa_man1_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    koopa_install_app \
        --installer='python' \
        --name='python3.13' \
        "$@"
    (
        koopa_cd "${dict['bin_prefix']}"
        koopa_ln 'python3.13' 'python3'
        koopa_ln 'python3.13' 'python'
        koopa_cd "${dict['man1_prefix']}"
        koopa_ln 'python3.13.1' 'python3.1'
        koopa_ln 'python3.13.1' 'python.1'
    )
    return 0
}
