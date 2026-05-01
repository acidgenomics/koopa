#!/usr/bin/env bash

_koopa_install_user_spacemacs() {
    _koopa_install_app \
        --name='spacemacs' \
        --prefix="$(_koopa_spacemacs_prefix)" \
        --user \
        "$@"
}
