#!/usr/bin/env bash

koopa_install_pygments() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pygmentize' \
        --name='pygments' \
        "$@"
}
