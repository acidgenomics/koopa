#!/usr/bin/env bash

koopa_locate_brew() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        "$(koopa_homebrew_prefix)/Homebrew/bin/brew" \
        "$@"
}
