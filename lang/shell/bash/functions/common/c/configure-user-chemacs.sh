#!/usr/bin/env bash

koopa_configure_user_chemacs() {
    koopa_configure_app \
        --name='chemacs' \
        --user \
        "$@"
}
