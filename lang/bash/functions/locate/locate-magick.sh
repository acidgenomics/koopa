#!/usr/bin/env bash

_koopa_locate_magick() {
    _koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='magick' \
        "$@"
}
