#!/usr/bin/env bash

koopa_locate_svn() {
    koopa_locate_app \
        --app-name='subversion' \
        --bin-name='svn'
        "$@" \
}
