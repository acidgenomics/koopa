#!/usr/bin/env bash

koopa_update_prelude_emacs() {
    koopa_update_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}
