#!/usr/bin/env bash

_koopa_uninstall_user_prelude_emacs() {
    _koopa_uninstall_app \
        --name='prelude-emacs' \
        --prefix="$(_koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}
