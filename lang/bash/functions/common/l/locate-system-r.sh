#!/usr/bin/env bash

koopa_locate_system_r() {
    local cmd
    if koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/R'
    else
        cmd='/usr/bin/R'
    fi
    koopa_locate_app "$cmd"
}
