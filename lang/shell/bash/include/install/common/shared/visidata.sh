#!/usr/bin/env bash

# FIXME This isn't linking libexec/share/man/man1 correctly.

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='visidata' \
        "$@"
}
