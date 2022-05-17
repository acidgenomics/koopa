#!/usr/bin/env bash

koopa_uninstall_cmake() {
    koopa_uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
}
