#!/usr/bin/env bash

koopa_uninstall_subversion() {
    koopa_uninstall_app \
        --name='subversion' \
        --unlink-in-bin='svn' \
        "$@"
}
