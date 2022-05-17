#!/usr/bin/env bash

# FIXME Need to add updated recipe support for this.
# https://www.gnu.org/software/gzip/

koopa_locate_gzip() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='gzip' \
        --opt-name='gzip'
}
