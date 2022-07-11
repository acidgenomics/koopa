#!/usr/bin/env bash

koopa_uninstall_openjdk() {
    local uninstall_args
    uninstall_args=(
        '--name-fancy=Adoptium Temurin OpenJDK'
        '--name=openjdk'
        '--unlink-in-bin=jar'
        '--unlink-in-bin=java'
        '--unlink-in-bin=javac'
    )
    # Reset 'default-java' on Linux, when possible.
    if koopa_is_linux
    then
        uninstall_args+=('--platform=linux')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
    return 0
}
