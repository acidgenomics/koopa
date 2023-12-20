#!/usr/bin/env bash

koopa_locate_magick() {
    koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='magick' \
        "$@"
}
