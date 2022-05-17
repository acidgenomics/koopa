#!/usr/bin/env bash

koopa_locate_whoami() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='whoami' \
        --opt-name='coreutils'
}
