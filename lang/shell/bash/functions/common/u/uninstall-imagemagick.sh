#!/usr/bin/env bash

koopa_uninstall_imagemagick() {
    koopa_uninstall_app \
        --name='imagemagick' \
        --link-in-bin='magick' \
        "$@"
}
