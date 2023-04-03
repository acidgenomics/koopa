#!/usr/bin/env bash

koopa_locate_system_rscript() {
    local cmd
    if koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/Rscript'
    else
        cmd='/usr/bin/Rscript'
    fi
    koopa_locate_app "$cmd"
}
