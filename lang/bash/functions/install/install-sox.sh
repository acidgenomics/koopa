#!/usr/bin/env bash

# FIXME This isn't linking 'sox.1' into man correctly currently.

_koopa_install_sox() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='sox' \
        "$@"
}
