#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

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
