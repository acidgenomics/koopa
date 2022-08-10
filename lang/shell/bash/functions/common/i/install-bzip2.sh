#!/usr/bin/env bash

koopa_install_bzip2() {
    koopa_install_app \
        --link-in-bin='bunzip2' \
        --link-in-bin='bzcat' \
        --link-in-bin='bzcmp' \
        --link-in-bin='bzdiff' \
        --link-in-bin='bzegrep' \
        --link-in-bin='bzfgrep' \
        --link-in-bin='bzgrep' \
        --link-in-bin='bzip2' \
        --link-in-bin='bzip2recover' \
        --link-in-bin='bzless' \
        --link-in-bin='bzmore' \
        --name='bzip2' \
        "$@"
}
