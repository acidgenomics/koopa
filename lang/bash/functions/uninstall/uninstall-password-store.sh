#!/usr/bin/env bash

_koopa_uninstall_password_store() {
    _koopa_uninstall_app \
        --name='password-store' \
        "$@"
}
