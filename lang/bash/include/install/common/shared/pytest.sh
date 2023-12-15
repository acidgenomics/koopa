#!/usr/bin/env bash

main() {
    local -A app dict
    local -a plugins
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_python_package
    app['python']="${dict['prefix']}/libexec/bin/python3"
    koopa_assert_is_executable "${app['python']}"
    plugins+=('pytest-cov')
    koopa_python_pip_install \
        --python="${app['python']}" \
        "${plugins[@]}"
    return 0
}
