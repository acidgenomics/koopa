#!/usr/bin/env bash

_koopa_uninstall_user_spacevim() {
    _koopa_uninstall_app \
        --name='spacevim' \
        --prefix="$(_koopa_spacevim_prefix)" \
        --user \
        "$@"
}
