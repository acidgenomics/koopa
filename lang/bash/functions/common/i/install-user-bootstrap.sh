#!/usr/bin/env bash

# FIXME This isn't working on work laptop.
# FIXME But running script directly does work, so need to debug.

koopa_install_user_bootstrap() {
    koopa_install_app \
        --name='bootstrap' \
        --user \
        "$@"
}
