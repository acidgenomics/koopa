#!/usr/bin/env bash

koopa_uninstall_imagemagick() {
    koopa_uninstall_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        --link-in-bin='magick' \
        "$@"
}
