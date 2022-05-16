#!/usr/bin/env bash

koopa_locate_scp() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='scp' \
        --opt-name='openssh'
}
