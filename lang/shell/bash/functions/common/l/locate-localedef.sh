#!/usr/bin/env bash

koopa_locate_localedef() {
    if koopa_is_alpine
    then
        koopa_alpine_locate_localedef
    else
        koopa_locate_app '/usr/bin/localedef'
    fi
}
