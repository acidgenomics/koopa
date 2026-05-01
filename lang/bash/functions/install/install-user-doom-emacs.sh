#!/usr/bin/env bash

_koopa_install_user_doom_emacs() {
    _koopa_install_app \
        --name='doom-emacs' \
        --prefix="$(_koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
