#!/usr/bin/env bash

# FIXME Install this from source instead -- conda is having build issues on
# macOS that I need to debug.

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='sambamba'
}
