#!/usr/bin/env bash

_koopa_locate_magick_core_config() {
    _koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='MagickCore-config' \
        "$@"
}
