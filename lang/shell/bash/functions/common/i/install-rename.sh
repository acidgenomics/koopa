#!/usr/bin/env bash

koopa_install_rename() {
    koopa_install_app \
        --installer='perl-package' \
        --link-in-bin='bin/rename' \
        --name='rename' \
        "$@"
}
