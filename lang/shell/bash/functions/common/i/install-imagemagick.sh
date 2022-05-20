#!/usr/bin/env bash

koopa_install_imagemagick() {
    koopa_install_app \
        --link-in-bin='bin/magick' \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}
