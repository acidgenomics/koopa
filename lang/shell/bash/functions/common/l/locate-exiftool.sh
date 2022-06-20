#!/usr/bin/env bash

# FIXME Rework this to split out to separate opt prefix.

koopa_locate_exiftool() {
    koopa_locate_app \
        --app-name='exiftool' \
        --opt-name='perl-packages'
}
