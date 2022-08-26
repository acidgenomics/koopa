#!/usr/bin/env bash

koopa_locate_pcregrep() {
    koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2grep' \
        "$@" 
}
