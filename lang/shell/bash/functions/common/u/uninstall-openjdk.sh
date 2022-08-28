#!/usr/bin/env bash

# FIXME We should create a Linux-specific wrapper here.

koopa_uninstall_openjdk() {
    # """
    # Reset 'default-java' on Linux, when possible.
    # """
    local uninstall_args
    uninstall_args=(
        '--name=openjdk'
    )
    if koopa_is_linux
    then
        uninstall_args+=('--platform=linux')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
    return 0
}
