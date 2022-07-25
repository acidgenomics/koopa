#!/usr/bin/env bash

# FIXME Hitting this issue on Linux VM:
# curses module not found

koopa_install_glances() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='glances' \
        --name='glances' \
        "$@"
}
