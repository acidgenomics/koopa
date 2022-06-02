#!/usr/bin/env bash

koopa_uninstall_latch() {
    koopa_uninstall_app \
        --name-fancy='LatchBio SDK' \
        --name='latch' \
        --unlink-in-bin='latch' \
        "$@"
}
