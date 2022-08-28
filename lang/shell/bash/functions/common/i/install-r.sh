#!/usr/bin/env bash

# FIXME Consider symlinking '/opt/koopa/bin/R' to '/usr/local/bin/R'
# on macOS, so RStudio works.

koopa_install_r() {
    koopa_install_app \
        --name='r' \
        "$@"
}
