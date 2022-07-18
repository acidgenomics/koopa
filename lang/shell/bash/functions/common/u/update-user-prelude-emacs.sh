#!/usr/bin/env bash

koopa_update_user_prelude_emacs() {
    koopa_update_app \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}
