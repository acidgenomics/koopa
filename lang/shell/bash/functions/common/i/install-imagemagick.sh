#!/usr/bin/env bash

koopa_install_imagemagick() {
    koopa_install_app \
        --link-in-bin='magick' \
        --name='imagemagick' \
        "$@"
}
