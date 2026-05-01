#!/usr/bin/env bash

_koopa_locate_doom() {
    _koopa_locate_app \
        "$(_koopa_doom_emacs_prefix)/bin/doom" \
        "$@"
}
