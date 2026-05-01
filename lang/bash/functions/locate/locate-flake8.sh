#!/usr/bin/env bash

_koopa_locate_flake8() {
    _koopa_locate_app \
        --app-name='flake8' \
        --bin-name='flake8' \
        "$@"
}
