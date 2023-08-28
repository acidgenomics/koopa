#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-package' \
        --name='scons' \
        -D --package-name='SCons'
}
