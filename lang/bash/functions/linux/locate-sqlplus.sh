#!/usr/bin/env bash

_koopa_linux_locate_sqlplus() {
    _koopa_locate_app \
        '/usr/bin/sqlplus' \
        "$@"
}
