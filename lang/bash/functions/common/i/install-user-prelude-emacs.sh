#!/usr/bin/env bash

koopa_install_user_prelude_emacs() {
    koopa_install_app \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}
