#!/usr/bin/env bash

_koopa_uninstall_user_spacemacs() {
    _koopa_uninstall_app \
        --name='spacemacs' \
        --prefix="$(_koopa_spacemacs_prefix)" \
        --user \
        "$@"
}
