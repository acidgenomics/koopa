#!/usr/bin/env bash

koopa_install_cairo() { # {{{3
    koopa_install_app \
        --name-fancy='Cairo' \
        --name='cairo' \
        "$@"
}

koopa_uninstall_cairo() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Cairo' \
        --name='cairo' \
        "$@"
}
