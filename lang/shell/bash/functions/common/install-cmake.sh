#!/usr/bin/env bash

koopa_install_cmake() { # {{{3
    koopa_install_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
}

koopa_uninstall_cmake() { # {{{3
    koopa_uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}
