#!/usr/bin/env bash

# FIXME This is Linux specific.

koopa_locate_sqlplus() {
    koopa_locate_app \
        '/usr/bin/sqlplus' \
        "$@"
}
