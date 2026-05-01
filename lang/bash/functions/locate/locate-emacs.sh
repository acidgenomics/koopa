#!/usr/bin/env bash

_koopa_locate_emacs() {
    _koopa_locate_app \
        --app-name='emacs' \
        --bin-name='emacs' \
        "$@"
}
