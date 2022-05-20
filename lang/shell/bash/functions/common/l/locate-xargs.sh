#!/usr/bin/env bash

koopa_locate_xargs() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='xargs' \
        --opt-name='findutils'
}
