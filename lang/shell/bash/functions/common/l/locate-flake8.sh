#!/usr/bin/env bash

koopa_locate_flake8() {
    koopa_locate_app \
        --app-name='flake8' \
        --bin-name='flake8' \
        "$@"
}
