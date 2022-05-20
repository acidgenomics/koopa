#!/usr/bin/env bash

koopa_uninstall_tcl_tk() {
    koopa_uninstall_app \
        --name-fancy='Tcl/Tk' \
        --name='tcl-tk' \
        "$@"
}
