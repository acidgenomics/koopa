#!/usr/bin/env bash

koopa_locate_cpan() {
    koopa_locate_app \
        --app-name='perl' \
        --bin-name='cpan'
        "$@" \
}
