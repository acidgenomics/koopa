#!/usr/bin/env bash

koopa_locate_yes() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gyes' \
        "$@"
}
