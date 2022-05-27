#!/usr/bin/env bash

# NOTE Consider installing Dracula color support.
# https://draculatheme.com/pygments

koopa_install_pygments() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pygmentize' \
        --name='pygments' \
        "$@"
}
