#!/usr/bin/env bash

_koopa_locate_gsl_config() {
    _koopa_locate_app \
        --app-name='gsl' \
        --bin-name='gsl-config' \
        "$@"
}
