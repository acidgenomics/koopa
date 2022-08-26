#!/usr/bin/env bash

koopa_locate_realpath() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grealpath' \
        "$@" 
}
