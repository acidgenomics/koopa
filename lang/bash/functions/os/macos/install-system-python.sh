#!/usr/bin/env bash

_koopa_macos_install_system_python() {
    local -A dict
    dict['python_version']="$(_koopa_python_major_minor_version)"
    _koopa_install_app \
        --installer='python' \
        --name="python${dict['python_version']}" \
        --platform='macos' \
        --prefix="$(_koopa_macos_python_prefix)" \
        --system \
        "$@"
}
