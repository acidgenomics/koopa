#!/usr/bin/env bash

# FIXME This currently returns note about skipping link for 'conda.1'
# man file. Need to rethink this approach.

koopa_install_conda() {
    koopa_install_app \
        --link-in-bin='conda' \
        --name='conda' \
        "$@"
}
