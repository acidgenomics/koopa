#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='freetype' \
        -D '--disable-static' \
        -D '--enable-freetype-config' \
        -D '--enable-shared=yes' \
        -D '--without-harfbuzz'
}
