#!/usr/bin/env bash

# FIXME Need to add install support for this.

koopa_locate_unzip() {
    koopa_locate_app \
        --app-name='unzip' \
        --bin-name='unzip' \
        "$@"
}
