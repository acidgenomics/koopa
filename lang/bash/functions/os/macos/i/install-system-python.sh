#!/usr/bin/env bash

koopa_macos_install_system_python() {
    local -A dict
    dict['python_version']="$(koopa_python_major_minor_version)"
    koopa_install_app \
        --installer='python' \
        --name="python${dict['python_version']}" \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}
