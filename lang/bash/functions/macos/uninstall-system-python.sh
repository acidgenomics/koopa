#!/usr/bin/env bash

_koopa_macos_uninstall_system_python() {
    local -A dict
    dict['python_version']="$(_koopa_python_major_minor_version)"
    _koopa_uninstall_app \
        --name="python${dict['python_version']}" \
        --platform='macos' \
        --system \
        --uninstaller='python' \
        "$@"
}
