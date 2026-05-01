#!/usr/bin/env bash

_koopa_locate_yacc() {
    _koopa_locate_app \
        --app-name='bison' \
        --bin-name='yacc' \
        "$@"
}
