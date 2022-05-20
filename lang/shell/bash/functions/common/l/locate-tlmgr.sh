#!/usr/bin/env bash

koopa_locate_tlmgr() {
    if koopa_is_macos
    then
        koopa_locate_app '/Library/TeX/texbin/tlmgr'
    else
        koopa_locate_app \
            --allow-in-path \
            --app-name='tlmgr'
    fi
}
