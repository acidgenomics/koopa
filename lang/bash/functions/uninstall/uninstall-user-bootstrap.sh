#!/usr/bin/env bash

_koopa_uninstall_user_bootstrap() {
    _koopa_uninstall_app \
        --name='bootstrap' \
        --prefix="$(_koopa_bootstrap_prefix)" \
        --user \
        "$@"
}
