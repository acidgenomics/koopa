#!/usr/bin/env bash

koopa_locate_groups() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='groups' \
        --opt-name='coreutils'
}
