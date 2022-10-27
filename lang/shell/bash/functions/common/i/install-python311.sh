#!/usr/bin/env bash

# FIXME Create symlink at '/opt/koopa/app/python'.
# FIXME Create symlink at '/opt/koopa/opt/python'.

koopa_install_python311() {
    koopa_install_app \
        --installer='python' \
        --name='python3.11' \
        "$@"
}
