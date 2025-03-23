#!/usr/bin/env bash

koopa_locate_autoupdate() {
    koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoupdate' \
        "$@"
}
