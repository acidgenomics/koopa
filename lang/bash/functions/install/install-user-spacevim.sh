#!/usr/bin/env bash

_koopa_install_user_spacevim() {
    _koopa_install_app \
        --name='spacevim' \
        --prefix="$(_koopa_spacevim_prefix)" \
        --user \
        "$@"
}
