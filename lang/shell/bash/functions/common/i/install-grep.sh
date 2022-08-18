#!/usr/bin/env bash

koopa_install_grep() {
    koopa_install_app \
        --link-in-bin='egrep' \
        --link-in-bin='fgrep' \
        --link-in-bin='grep' \
        --name='grep' \
        "$@"
}
