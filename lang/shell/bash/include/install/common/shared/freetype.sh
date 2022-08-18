#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='freetype' \
        -D '--enable-freetype-config' \
        -D '--enable-shared=yes' \
        -D '--enable-static=yes' \
        -D '--without-harfbuzz' \
        "$@"
}
