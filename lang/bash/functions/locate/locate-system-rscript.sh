#!/usr/bin/env bash

_koopa_locate_system_rscript() {
    local cmd
    if _koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/Rscript'
    else
        cmd='/usr/bin/Rscript'
    fi
    _koopa_locate_app "$cmd"
}
