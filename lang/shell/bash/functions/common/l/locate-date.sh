#!/usr/bin/env bash

koopa_locate_date() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='date' \
        --opt-name='coreutils'
}
