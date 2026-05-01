#!/usr/bin/env bash

_koopa_locate_svn() {
    _koopa_locate_app \
        --app-name='subversion' \
        --bin-name='svn' \
        "$@"
}
