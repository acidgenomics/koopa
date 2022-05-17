#!/usr/bin/env bash

koopa_install_freetype() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='freetype' \
        -D '--enable-freetype-config' \
        -D '--enable-shared=yes' \
        -D '--enable-static=yes' \
        -D '--without-harfbuzz' \
        "$@"
}
