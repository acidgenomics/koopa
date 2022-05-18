#!/usr/bin/env bash

koopa_uninstall_password_store() {
    koopa_uninstall_app \
        --name='password-store' \
        --unlink-in-bin='pass' \
        "$@"
}
