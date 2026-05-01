#!/usr/bin/env bash

_koopa_locate_cpan() {
    _koopa_locate_app \
        --app-name='perl' \
        --bin-name='cpan' \
        "$@"
}
