#!/usr/bin/env bash

koopa_linux_uninstall_openjdk() {
    # """
    # Reset 'default-java' on Linux, when possible.
    # """
    koopa_uninstall_app \
        --name='openjdk' \
        --platform='linux' \
        "$@"
}
