#!/usr/bin/env bash

koopa_locate_yacc() {
    koopa_locate_app \
        --app-name='bison' \
        --bin-name='yacc' \
        "$@"
}
