#!/usr/bin/env bash

_koopa_uninstall_user_doom_emacs() {
    _koopa_uninstall_app \
        --name='doom-emacs' \
        --prefix="$(_koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
