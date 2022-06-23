#!/usr/bin/env bash

koopa_install_cmake() {
    koopa_install_app \
        --link-in-bin='bin/cmake' \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
}
