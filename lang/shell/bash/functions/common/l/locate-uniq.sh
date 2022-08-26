#!/usr/bin/env bash

koopa_locate_uniq() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guniq' \
        "$@" 
}
