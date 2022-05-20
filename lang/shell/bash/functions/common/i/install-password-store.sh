#!/usr/bin/env bash

koopa_install_password_store() {
    koopa_install_app \
        --link-in-bin='bin/pass' \
        --name='password-store' \
        "$@"
}
