#!/usr/bin/env bash

koopa_install_subversion() {
    koopa_install_app \
        --link-in-bin='svn' \
        --name='subversion' \
        "$@"
}
