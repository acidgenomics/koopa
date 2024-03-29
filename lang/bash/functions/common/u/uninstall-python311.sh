#!/usr/bin/env bash

koopa_uninstall_python311() {
    local -A dict
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    koopa_uninstall_app \
        --name='python3.11' \
        "$@"
    koopa_rm  \
        "${dict['app_prefix']}/python" \
        "${dict['bin_prefix']}/python" \
        "${dict['bin_prefix']}/python3" \
        "${dict['opt_prefix']}/python"
    return 0
}
