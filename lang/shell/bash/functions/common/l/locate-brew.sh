#!/usr/bin/env bash

koopa_locate_brew() {
    koopa_locate_app \
        "$(koopa_homebrew_prefix)/Homebrew/bin/brew" \
        "$@"
}
