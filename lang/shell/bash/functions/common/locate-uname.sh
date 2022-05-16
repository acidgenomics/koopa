#!/usr/bin/env bash

koopa_locate_uname() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='uname' \
        --opt-name='coreutils'
}
