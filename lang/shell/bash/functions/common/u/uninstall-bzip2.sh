#!/usr/bin/env bash

koopa_uninstall_bzip2() {
    koopa_uninstall_app \
        --name='bzip2' \
        --unlink-in-bin='bunzip2' \
        --unlink-in-bin='bzcat' \
        --unlink-in-bin='bzcmp' \
        --unlink-in-bin='bzdiff' \
        --unlink-in-bin='bzegrep' \
        --unlink-in-bin='bzfgrep' \
        --unlink-in-bin='bzgrep' \
        --unlink-in-bin='bzip2' \
        --unlink-in-bin='bzip2recover' \
        --unlink-in-bin='bzless' \
        --unlink-in-bin='bzmore' \
        "$@"
}

