#!/usr/bin/env bash

main() {
    # """
    # Not needed on Linux, where 'iconv.h' is provided by glibc.
    # """
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='libiconv' \
        -D '--disable-debug' \
        -D '--disable-dependency-tracking' \
        -D '--disable-static' \
        -D '--enable-extra-encodings' \
        "$@"
}
