#!/usr/bin/env bash

koopa_uninstall_user_prelude_emacs() {
    koopa_uninstall_app \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}
