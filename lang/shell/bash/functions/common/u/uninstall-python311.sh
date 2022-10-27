#!/usr/bin/env bash

# FIXME Delete symlink at '/opt/koopa/app/python'.
# FIXME Delete symlink at '/opt/koopa/opt/python'.

koopa_uninstall_python311() {
    koopa_uninstall_app \
        --name='python3.11' \
        "$@"
}
