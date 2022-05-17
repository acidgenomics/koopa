#!/usr/bin/env bash

koopa_uninstall_fltk() {
    koopa_uninstall_app \
        --name-fancy='FLTK' \
        --name='fltk' \
        "$@"
}
