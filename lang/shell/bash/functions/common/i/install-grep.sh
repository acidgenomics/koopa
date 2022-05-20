#!/usr/bin/env bash

koopa_install_grep() {
    koopa_install_app \
        --activate-opt='pcre' \
        --installer='gnu-app' \
        --link-in-bin='bin/egrep' \
        --link-in-bin='bin/fgrep' \
        --link-in-bin='bin/grep' \
        --name='grep' \
        "$@"
}
