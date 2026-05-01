#!/usr/bin/env bash

_koopa_locate_system_r() {
    local cmd
    if _koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/R'
    else
        cmd='/usr/bin/R'
    fi
    _koopa_locate_app "$cmd"
}
