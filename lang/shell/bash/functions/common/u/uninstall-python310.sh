#!/usr/bin/env bash

koopa_uninstall_python310() {
    local dict
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    koopa_uninstall_app \
        --name='python3.10' \
        "$@"
    koopa_alert "Unlinking 'python' and 'python3'."
    koopa_rm  \
        "${dict['app_prefix']}/python" \
        "${dict['bin_prefix']}/python" \
        "${dict['bin_prefix']}/python3" \
        "${dict['opt_prefix']}/python"
    return 0
}
