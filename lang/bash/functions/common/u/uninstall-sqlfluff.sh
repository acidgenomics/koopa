#!/usr/bin/env bash

koopa_uninstall_sqlfluff() {
    koopa_uninstall_app \
        --name='sqlfluff' \
        "$@"
}
