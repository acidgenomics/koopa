#!/usr/bin/env bash

# FIXME Need to add recipe support for this.

koopa_locate_man() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='man' \
        --opt-name='man-db'
}
