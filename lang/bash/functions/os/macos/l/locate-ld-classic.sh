#!/usr/bin/env bash

koopa_macos_locate_ld_classic() {
    koopa_locate_app \
        '/Library/Developer/CommandLineTools/usr/bin/ld-classic' \
        "$@"
}
