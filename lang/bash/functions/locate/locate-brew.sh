#!/usr/bin/env bash

_koopa_locate_brew() {
    _koopa_locate_app \
        "$(_koopa_homebrew_prefix)/bin/brew" \
        "$@"
}
