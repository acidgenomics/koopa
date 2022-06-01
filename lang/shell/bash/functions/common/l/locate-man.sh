#!/usr/bin/env bash

koopa_locate_man() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='man' \
        --opt-name='man-db'
}
