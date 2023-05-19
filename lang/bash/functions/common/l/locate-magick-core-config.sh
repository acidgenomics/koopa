#!/usr/bin/env bash

koopa_locate_magick_core_config() {
    koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='MagickCore-config' \
        "$@"
}
