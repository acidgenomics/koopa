#!/usr/bin/env bash

koopa_install_grep() {
    koopa_install_app \
        --activate-opt='pcre' \
        --installer='gnu-app' \
        --link-in-bin='egrep' \
        --link-in-bin='fgrep' \
        --link-in-bin='grep' \
        --name='grep' \
        "$@"
}
