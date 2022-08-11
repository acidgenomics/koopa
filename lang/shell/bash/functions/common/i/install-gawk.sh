#!/usr/bin/env bash

# FIXME Need to create 'awk.1' symlink during install.
# FIXME Need to break this out to separate install script instead of
# using 'gnu-app' approach.

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_gawk() {
    koopa_install_app \
        --installer='gnu-app' \
        --activate-opt='gettext' \
        --activate-opt='mpfr' \
        --activate-opt='readline' \
        --link-in-bin='awk' \
        --link-in-bin='gawk' \
        --name='gawk' \
        "$@"
}
