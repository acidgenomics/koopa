#!/usr/bin/env bash

_koopa_uninstall_python311() {
    local -A dict
    dict['app_prefix']="$(_koopa_app_prefix)"
    dict['bin_prefix']="$(_koopa_bin_prefix)"
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    _koopa_uninstall_app \
        --name='python3.11' \
        "$@"
    _koopa_rm  \
        "${dict['app_prefix']}/python" \
        "${dict['bin_prefix']}/python" \
        "${dict['bin_prefix']}/python3" \
        "${dict['opt_prefix']}/python"
    return 0
}
